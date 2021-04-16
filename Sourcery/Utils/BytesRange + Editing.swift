//
//  BytesRange + Editing.swift
//  Sourcery
//
//  Created by Evgeniy Gubin on 16.04.2021.
//  Copyright © 2021 Pixle. All rights reserved.
//

import class SourceryRuntime.BytesRange
import struct SourceryFramework.ByteRange
import struct SourceryFramework.ByteCount

extension BytesRange {
    /*
     See ByteRange.changingContent(_:)
     */
    func changingContent(_ change: ByteRange) -> BytesRange {
        let byteRange = ByteRange(bytesRange: self)
        let result = byteRange.editingContent(change)
        return BytesRange(byteRange: result)
    }
}
