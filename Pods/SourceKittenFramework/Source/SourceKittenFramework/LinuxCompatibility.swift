//
//  LinuxCompatibility.swift
//  SourceKitten
//
//  Created by JP Simard on 8/19/16.
//  Copyright © 2016 SourceKitten. All rights reserved.
//

import Foundation

extension Array {
    public func bridge() -> NSArray {
#if os(Linux)
        return NSArray(array: self)
#else
        return self as NSArray
#endif
    }
}

extension CharacterSet {
    public func bridge() -> NSCharacterSet {
#if os(Linux)
        return _bridgeToObjectiveC()
#else
        return self as NSCharacterSet
#endif
    }
}

extension Dictionary {
    public func bridge() -> NSDictionary {
#if os(Linux)
        return NSDictionary(dictionary: self)
#else
        return self as NSDictionary
#endif
    }
}

extension NSString {
    public func bridge() -> String {
#if os(Linux)
        return _bridgeToSwift()
#else
        return self as String
#endif
    }
}

extension String {
    public func bridge() -> NSString {
#if os(Linux)
        return NSString(string: self)
#else
        return self as NSString
#endif
    }
}
