//
//  Parameter.swift
//  SourceKitten
//
//  Created by JP Simard on 10/27/15.
//  Copyright © 2015 SourceKitten. All rights reserved.
//

#if !os(Linux)

#if SWIFT_PACKAGE
import Clang_C
#endif

public struct Parameter {
    public let name: String
    public let discussion: [Text]

    init(comment: CXComment) {
        name = comment.paramName() ?? "<none>"
        discussion = comment.paragraph().paragraphToString()
    }
}

#endif
