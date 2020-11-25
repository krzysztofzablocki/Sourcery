//
//  UID.swift
//  SourceKitten
//
//  Created by Norio Nomura on 2/07/18.
//  Copyright © 2018 SourceKitten. All rights reserved.
//

#if SWIFT_PACKAGE
import SourceKit
#endif

/// Swift representation of sourcekitd_uid_t
public struct UID: Hashable {
    let sourcekitdUID: sourcekitd_uid_t
    init(_ uid: sourcekitd_uid_t) {
        self.sourcekitdUID = uid
    }

    public init(_ string: String) {
        self.init(sourcekitd_uid_get_from_cstr(string)!)
    }

    public init<T>(_ rawRepresentable: T) where T: RawRepresentable, T.RawValue == String {
        self.init(rawRepresentable.rawValue)
    }

    var string: String {
        return String(cString: sourcekitd_uid_get_string_ptr(sourcekitdUID)!)
    }
}

extension UID: CustomStringConvertible {
    public var description: String {
        return string
    }
}

extension UID: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}
