//
//  File+Hashable.swift
//  SourceKitten
//
//  Created by JP Simard on 2019-05-12.
//  Copyright (c) 2019 SourceKitten. All rights reserved.
//

extension File: Hashable {
    public static func == (lhs: File, rhs: File) -> Bool {
        switch (lhs.path, rhs.path) {
        case let (.some(lhsPath), .some(rhsPath)):
            return lhsPath == rhsPath
        case (.none, .none):
            return lhs.contents == rhs.contents
        default:
            return false
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(path ?? contents)
    }
}
