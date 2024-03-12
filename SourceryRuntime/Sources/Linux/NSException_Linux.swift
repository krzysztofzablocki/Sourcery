#if !canImport(ObjectiveC)
import Foundation

public class NSException {
    static func raise(_ name: String, format: String, arguments: CVaListPointer) {
        fatalError ("\(name) exception: \(NSString(format: format, arguments: arguments))")
    }

    static func raise(_ name: String) {
        fatalError("\(name) exception")
    }
}

public extension NSExceptionName {
    static var parseErrorException = "parseErrorException"
}
#endif
