//
//  SwiftVersion.swift
//  SourceKitten
//
//  Copyright © 2020 SourceKitten. All rights reserved.
//

/// The version triple of the Swift compiler, for example "5.1.3"
struct SwiftVersion: RawRepresentable, Comparable {
    typealias RawValue = String

    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Comparable
    static func < (lhs: SwiftVersion, rhs: SwiftVersion) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

extension SwiftVersion {
    static let beforeFiveDotOne = SwiftVersion(rawValue: "1.0.0")
    static let fiveDotOne = SwiftVersion(rawValue: "5.1.0")

    /// The version of the Swift compiler providing SourceKit.  Accurate only from
    /// compiler version 5.1.0: earlier versions return `.beforeFiveDotOne`.
    static let current: SwiftVersion = {
        if let result = try? Request.compilerVersion.send(),
            let major = result["key.version_major"] as? Int64,
            let minor = result["key.version_minor"] as? Int64,
            let patch = result["key.version_patch"] as? Int64 {
            return SwiftVersion(rawValue: "\(major).\(minor).\(patch)")
        }
        return .beforeFiveDotOne
    }()
}
