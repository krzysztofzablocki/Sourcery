//
//  EnumsDefaults.swift
//  TemplatesTests
//
//  Created by Stéphane Copin on 11/2/18.
//  Copyright © 2018 Pixle. All rights reserved.
//

import Foundation

protocol Protocol {

}

final class DefaultImplementation: Protocol {

}

enum AssociatedVariablesEnum {
	// sourcery: a = '"test"', b = "true", c = "0", d = "nil"
	case one(a: String, b: Bool, c: Int, d: Any?)
	// sourcery: 0 = '"test"'
	case two(String, Bool, Int, d: Any?)
	// sourcery: a = '"test"', d = "nil", c = "true", 1 = "true"
	case three(a: String, b: Bool, c: Int, d: Any?)
	// sourcery: a = '"test"', c = "true", 1 = "true", d = "DefaultImplementation()"
	case four(a: String, b: Bool, c: Int, d: Protocol)
}
