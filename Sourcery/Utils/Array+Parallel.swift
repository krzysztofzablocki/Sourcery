//
// Created by Krzysztof Zablocki on 06/01/2017.
// Copyright (c) 2017 Pixle. All rights reserved.
//

import Foundation

extension Array {
    func parallelFlatMap<T>(transform: (Element) throws -> [T]) throws -> [T] {
        return try parallelMap(transform).flatMap { $0 }
    }

    /// We have to roll our own solution because concurrentPerform will use slowPath if no NSApplication is available
    func parallelMap<T>(_ transform: (Element) throws -> T, progress: ((Int) -> Void)? = nil) throws -> [T] {
        let count = self.count
        let maxConcurrentJobs = ProcessInfo.processInfo.activeProcessorCount

        guard count > 1 && maxConcurrentJobs > 1 else {
            // skip GCD overhead if we'd only run one at a time anyway
            return try map(transform)
        }

        var result = [(Int, [T])]()
        result.reserveCapacity(count)
        let group = DispatchGroup()
        let uuid = NSUUID().uuidString
        let jobCount = Int(ceil(Double(count) / Double(maxConcurrentJobs)))

        let queueLabelPrefix = "io.pixle.Sourcery.map.\(uuid)"
        let resultAccumulatorQueue = DispatchQueue(label: "\(queueLabelPrefix).resultAccumulator")

        var mapError: Error?
        withoutActuallyEscaping(transform) { escapingtransform in
            for jobIndex in stride(from: 0, to: count, by: jobCount) {
                let queue = DispatchQueue(label: "\(queueLabelPrefix).\(jobIndex / jobCount)")
                queue.async(group: group) {
                    let jobElements = self[jobIndex..<Swift.min(count, jobIndex + jobCount)]
                    do {
                        let jobIndexAndResults = try (jobIndex, jobElements.map(escapingtransform))
                        resultAccumulatorQueue.sync {
                            result.append(jobIndexAndResults)
                        }
                    } catch {
                        resultAccumulatorQueue.sync {
                            mapError = error
                        }
                    }
                }
            }
            group.wait()
        }
        if let mapError = mapError {
            throw mapError
        }
        return result.sorted { $0.0 < $1.0 }.flatMap { $0.1 }
    }
}
