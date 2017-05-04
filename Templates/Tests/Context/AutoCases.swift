//
//  AutoCases.swift
//  Templates
//
//  Created by Anton Domashnev on 03.05.17.
//  Copyright © 2017 Pixle. All rights reserved.
//

import Foundation

protocol AutoCases {}

/// The idea of the enum is taken from https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Enumerations.html#//apple_ref/doc/uid/TP40014097-CH12-ID145 as a simple example of Swift enumeration
enum CompassPoint: AutoCases {
    case north
    case south
    case east
    case west
}
