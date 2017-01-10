//
// Created by Krzysztof Zablocki on 06/01/2017.
// Copyright (c) 2017 Pixle. All rights reserved.
//

import Foundation

extension Array {
    func parallelFlatMap<T>(transform: @escaping ((Element) -> [T])) -> [T] {
        return parallelMap(transform).flatMap { $0 }
    }

    /// We have to roll our own solution because concurrentPerform will use slowPath if no NSApplication is available
    func parallelMap<T>(_ transform: @escaping ((Element) -> T), progress: ((Int) -> Void)? = nil) -> [T] {
        let count = self.count
        let maxConcurrentJobs = ProcessInfo.processInfo.activeProcessorCount

        guard count > 1 && maxConcurrentJobs > 1 else {
            // skip GCD overhead if we'd only run one at a time anyway
            return map(transform)
        }

        var result = [(Int, [T])]()
        result.reserveCapacity(count)
        let group = DispatchGroup()
        let uuid = NSUUID().uuidString
        let jobCount = Int(ceil(Double(count) / Double(maxConcurrentJobs)))

        let queueLabelPrefix = "io.pixle.Sourcery.map.\(uuid)"
        let resultAccumulatorQueue = DispatchQueue(label: "\(queueLabelPrefix).resultAccumulator")

        for jobIndex in stride(from: 0, to: count, by: jobCount) {
            let queue = DispatchQueue(label: "\(queueLabelPrefix).\(jobIndex / jobCount)")
            queue.async(group: group) {
                let jobElements = self[jobIndex..<Swift.min(count, jobIndex + jobCount)]
                let jobIndexAndResults = (jobIndex, jobElements.map(transform))
                resultAccumulatorQueue.sync {
                    result.append(jobIndexAndResults)
                }
            }
        }
        group.wait()
        return result.sorted { $0.0 < $1.0 }.flatMap { $0.1 }
    }
}
