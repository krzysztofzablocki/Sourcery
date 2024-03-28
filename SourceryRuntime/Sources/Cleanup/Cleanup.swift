//
// Created by Krzysztof Zablocki on 13/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

extension Protocol {
    public override func cleanUp() {
        super.cleanUp()
        self.associatedTypes = [:]
        self.genericRequirements = []
    }
}

extension Type {
    
    public func cleanUp() {
        self.rawVariables.forEach {
            $0.cleanUp()
        }
        self.rawVariables = []
        
        self.rawMethods.forEach {
            $0.cleanUp()
        }
        self.rawMethods = []
        
        self.rawSubscripts.forEach {
            $0.cleanUp()
        }
        self.rawSubscripts = []
        
        self.parent = nil
        
        self.typealiases.forEach { _, ta in
            ta.cleanUp()
        }
        self.typealiases = [:]
        
        supertype = nil
        
//        containedType.forEach {
//            $1.cleanUp()
//        }
        containedType = [:]
        
//        containedTypes.forEach {
//            $0.cleanUp()
//        }
        containedTypes = []
        
//        implements.forEach {
//            $1.cleanUp()
//        }
        implements = [:]
        
//        inherits.forEach {
//            $1.cleanUp()
//        }
        inherits = [:]
        
//        basedTypes.forEach {
//            $1.cleanUp()
//        }
        basedTypes = [:]
    }
}

extension Enum {
    public override func cleanUp() {
        super.cleanUp()
        self.cases = []
    }
}

extension Variable {
    public func cleanUp() {
        self.definedInType = nil
    }
}

extension MethodParameter {
    public func cleanUp() {
        self.type = nil
    }
}

extension Method {
    func cleanUp() {
        self.parameters.forEach {
            $0.cleanUp()
        }
        self.parameters = []
        
        self.returnType = nil
        self.definedInType = nil
    }
}

extension Subscript {
    func cleanUp() {
        self.parameters.forEach {
            $0.cleanUp()
        }
        self.parameters = []
        self.returnType = nil
        self.definedInType = nil
    }
}

extension Typealias {
    public func cleanUp() {
        self.type = nil
        self.parent = nil
    }
}
