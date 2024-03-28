//
// Created by Krzysztof Zablocki on 06/01/2017.
// Copyright (c) 2017 Pixle. All rights reserved.
//

import Foundation

public extension Array {
    func parallelFlatMap<T>(transform: (Element) -> [T]) -> [T] {
        return parallelMap(transform: transform).flatMap { $0 }
    }

    func parallelCompactMap<T>(transform: (Element) -> T?) -> [T] {
        return parallelMap(transform: transform).compactMap { $0 }
    }

    func parallelMap<T>(transform: (Element) -> T) -> [T] {
        var result = ContiguousArray<T?>(repeating: nil, count: count)
        return result.withUnsafeMutableBufferPointer { buffer in
            DispatchQueue.concurrentPerform(iterations: buffer.count) { idx in
                buffer[idx] = transform(self[idx])
            }
            return buffer.map { $0! }
        }
    }

    func parallelPerform(_ work: (Element) -> Void) {
        DispatchQueue.concurrentPerform(iterations: count) { idx in
            work(self[idx])
        }
    }
}
