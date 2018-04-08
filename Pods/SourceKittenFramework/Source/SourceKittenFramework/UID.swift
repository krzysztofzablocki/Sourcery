//
//  UID.swift
//  SourceKitten
//
//  Created by Norio Nomura on 2/07/18.
//  Copyright © 2018 SourceKitten. All rights reserved.
//

import Foundation
#if SWIFT_PACKAGE
import SourceKit
#endif

/// Swift representation of sourcekitd_uid_t
public struct UID {
    let uid: sourcekitd_uid_t
    init(_ uid: sourcekitd_uid_t) {
        self.uid = uid
    }

    public init(_ string: String) {
        self.init(sourcekitd_uid_get_from_cstr(string)!)
    }

    public init<T>(_ rawRepresentable: T) where T: RawRepresentable, T.RawValue == String {
        self.init(rawRepresentable.rawValue)
    }

    var string: String {
        return String(cString: sourcekitd_uid_get_string_ptr(uid)!)
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

extension UID: Hashable {
    public var hashValue: Int {
        return uid.hashValue
    }

    public static func == (lhs: UID, rhs: UID) -> Bool {
        return lhs.uid == rhs.uid
    }
}

extension UID: SourceKitObjectConvertible {
    public var sourcekitdObject: sourcekitd_object_t? {
        return sourcekitd_request_uid_create(uid)
    }
}
