//
//  String+Yams.swift
//  Yams
//
//  Created by Norio Nomura on 12/7/16.
//  Copyright (c) 2016 Yams. All rights reserved.
//

import Foundation

extension String {
    /// line number, column and contents at byteOffset.
    ///
    /// - Parameter byteOffset: Int
    /// - Returns: lineNumber: line number start from 1,
    ///            column: utf16 column start from 1,
    ///            contents: substring of line
    func lineNumberColumnAndContents(at byteOffset: Int) -> (lineNumber: Int, column: Int, contents: String)? {
        guard let index = utf8
            .index(utf8.startIndex, offsetBy: byteOffset, limitedBy: utf8.endIndex)?
            .samePosition(in: self) else { return nil }
        var number = 0
        var outStartIndex = startIndex, outEndIndex = startIndex, outContentsEndIndex = startIndex
        getLineStart(&outStartIndex, end: &outEndIndex, contentsEnd: &outContentsEndIndex,
                     for: startIndex..<startIndex)
        while (outEndIndex <= index && outEndIndex < endIndex) {
            number += 1
            let range = outEndIndex..<outEndIndex
            getLineStart(&outStartIndex, end: &outEndIndex, contentsEnd: &outContentsEndIndex,
                         for: range)
        }
        let utf16StartIndex = outStartIndex.samePosition(in: utf16)
        let utf16Index = index.samePosition(in: utf16)
        return (
            number + 1,
            utf16.distance(from: utf16StartIndex, to: utf16Index) + 1,
            substring(with: outStartIndex..<outEndIndex)
        )
    }

    /// substring indicated by line number.
    ///
    /// - Parameter line: line number starts from 0.
    /// - Returns: substring of line contains line ending characters
    func substring(at line: Int) -> String {
        var number = 0
        var outStartIndex = startIndex, outEndIndex = startIndex, outContentsEndIndex = startIndex
        getLineStart(&outStartIndex, end: &outEndIndex, contentsEnd: &outContentsEndIndex,
                     for: startIndex..<startIndex)
        while (number < line  && outEndIndex < endIndex) {
            number += 1
            let range = outEndIndex..<outEndIndex
            getLineStart(&outStartIndex, end: &outEndIndex, contentsEnd: &outContentsEndIndex,
                         for: range)
        }
        return substring(with: outStartIndex..<outEndIndex)
    }

    /// String appending newline if is not ending with newline.
    var endingWithNewLine: String {
        let isEndsWithNewLines = unicodeScalars.last.map(CharacterSet.newlines.contains) ?? false
        if isEndsWithNewLines {
            return self
        } else {
            return self + "\n"
        }
    }
}
