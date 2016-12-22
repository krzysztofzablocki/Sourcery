//
//  Diffable.swift
//  Sourcery
//
//  Created by Krzysztof Zabłocki on 22/12/2016.
//  Copyright © 2016 Pixle. All rights reserved.
//

import Foundation

typealias DiffableResult = [String]

protocol Diffable {

    /// Returns `DiffableResult` for the given objects.
    ///
    /// - Parameter object: Object to diff against.
    /// - Returns: Diffable results.
    func diffAgainst(_ object: Any?) -> DiffableResult
}

/// Phantom protocol for code generation
protocol AutoDiffable {}
