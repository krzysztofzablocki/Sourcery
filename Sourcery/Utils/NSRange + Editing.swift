//
// Created by hemet_000 on 14.04.2021.
//

import Foundation
import struct SourceryFramework.ByteRange
import struct SourceryFramework.ByteCount

extension NSRange {
    /*
     See ByteRange.changingContent(_:)
     */
    func changingContent(_ change: NSRange) -> NSRange {
        let byteRange = ByteRange(location: ByteCount(location), length: ByteCount(length))
        let changeByteRange = ByteRange(location: ByteCount(change.location), length: ByteCount(change.length))
        let result = byteRange.editingContent(changeByteRange)
        return NSRange(location: result.location.value, length: result.length.value)
    }
}
