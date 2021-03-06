import Foundation

/// Describes annotated declaration, i.e. type, method, variable, enum case
public protocol Annotated {
    /**
     All annotations of declaration stored by their name. Value can be `bool`, `String`, float `NSNumber`
     or array of those types if you use several annotations with the same name.
    
     **Example:**
     
     ```
     //sourcery: booleanAnnotation
     //sourcery: stringAnnotation = "value"
     //sourcery: numericAnnotation = 0.5
     
     [
      "booleanAnnotation": true,
      "stringAnnotation": "value",
      "numericAnnotation": 0.5
     ]
     ```
    */
    var annotations: [String: NSObject] { get }
}
