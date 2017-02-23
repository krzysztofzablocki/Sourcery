//
// Created by Krzysztof Zablocki on 23/01/2017.
// Copyright (c) 2017 Pixle. All rights reserved.
//

import Foundation

/// Phantom protocol for diffing
protocol AutoDiffable {}

/// Phantom protocol for equality
protocol AutoEquatable {}

/// Phantom protocol for equality
protocol AutoDescription {}

/// Phantom protocol for NSCoding
protocol AutoCoding {}

protocol AutoJSExport {}

/// Phantom protocol for NSCoding, Equatable and Diffable
protocol SourceryModel: AutoDiffable, AutoEquatable, AutoCoding, AutoDescription, AutoJSExport {}
