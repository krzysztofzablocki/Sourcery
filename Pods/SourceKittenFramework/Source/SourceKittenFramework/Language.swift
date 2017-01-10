//
//  Language.swift
//  SourceKitten
//
//  Created by JP Simard on 2015-01-03.
//  Copyright (c) 2015 SourceKitten. All rights reserved.
//

/// Language Enum.
public enum Language {
    /// Swift.
    case swift
    /// Objective-C.
    case objc
}

// MARK: - migration support
extension Language {
    @available(*, unavailable, renamed: "swift")
    public static var Swift: Language {
        fatalError()
    }

    @available(*, unavailable, renamed: "objc")
    public static var ObjC: Language {
        fatalError()
    }
}
