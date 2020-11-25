//
//  UIDRepresentable.swift
//  SourceKittenFramework
//
//  Created by Colton Schlosser on 7/16/19.
//  Copyright © 2019 SourceKitten. All rights reserved.
//

public protocol UIDRepresentable {
    var uid: UID { get }
}

extension UID: UIDRepresentable {
    public var uid: UID {
        return self
    }
}

extension String: UIDRepresentable {
    public var uid: UID {
        return UID(self)
    }
}
