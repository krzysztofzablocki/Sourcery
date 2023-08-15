//
//  Created by Sébastien Duperron on 03/01/2018.
//  Copyright © 2018 Pixle. All rights reserved.
//

import Foundation

/// :nodoc:
#if os(macOS)
@objcMembers
#endif
public final class BytesRange: NSObject, SourceryModel, Diffable {

    public let offset: Int64
    public let length: Int64

    public init(offset: Int64, length: Int64) {
        self.offset = offset
        self.length = length
    }

    public convenience init(range: (offset: Int64, length: Int64)) {
        self.init(offset: range.offset, length: range.length)
    }

    public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? BytesRange else {
            results.append("Incorrect type <expected: BytesRange, received: \(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "offset").trackDifference(actual: self.offset, expected: castObject.offset))
        results.append(contentsOf: DiffableResult(identifier: "length").trackDifference(actual: self.length, expected: castObject.length))
        return results
    }

// sourcery:inline:BytesRange.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            self.offset = aDecoder.decodeInt64(forKey: "offset")
            self.length = aDecoder.decodeInt64(forKey: "length")
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.offset, forKey: "offset")
            aCoder.encode(self.length, forKey: "length")
        }
// sourcery:end
}
