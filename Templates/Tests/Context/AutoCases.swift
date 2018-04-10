//
//  AutoCases.swift
//  Templates
//
//  Created by Anton Domashnev on 03.05.17.
//  Copyright © 2017 Pixle. All rights reserved.
//

import Foundation

protocol AutoCases {}

enum AutoCasesEnum: AutoCases {
    case north
    case south
    case east
    case west
}

enum AutoCasesOneValueEnum: AutoCases {
    case one
}

public enum AutoCasesHasAssociatedValuesEnum: AutoCases {
    case foo(test: String)
    case bar(number: Int)
}
