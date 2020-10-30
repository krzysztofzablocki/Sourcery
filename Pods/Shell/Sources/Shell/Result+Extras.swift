import Foundation

extension Result {
    var error: Failure? {
        switch self {
        case .failure(let failure):
            return failure
        default:
            return nil
        }
    }
    
    var value: Success? {
        switch self {
        case .success(let success):
            return success
        default:
            return nil
        }
    }
}
