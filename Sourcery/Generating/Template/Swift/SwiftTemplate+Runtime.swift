//
//  SwiftTemplate+Runtime.swift
//  Sourcery
//
//  Created by Krunoslav Zaher on 12/30/16.
//  Copyright © 2016 Pixle. All rights reserved.
//

import Foundation

func run() {
    let path = ProcessInfo().arguments[1]

    // swiftlint:disable:next force_cast
    let context = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! GenerationContext
    context.generate()
}

extension NSObject {
    func generate() {
        fatalError("This should never be called")
    }
}
