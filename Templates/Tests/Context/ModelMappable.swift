//
//  ModelMappable.swift
//  TemplatesTests
//
//  Created by Ben Vest on 2/13/18.
//  Copyright © 2018 Pixle. All rights reserved.
//

import Foundation

protocol ModelMappable { }

protocol ExampleMapping: ModelMappable {
  var string: String { get }
  var bool: Bool { get }
  // sourcery: coding="some_variable_with_a_long_key"
  var someVariable: Double { get }
  // sourcery: incomingType="Int"
  var someBoolThatsAnInt: Bool { get }
  // sourcery: incomingType="String"
  var someDateString: Date { get }
  var whenItEndsInID: String { get } // sub for uuid
}
