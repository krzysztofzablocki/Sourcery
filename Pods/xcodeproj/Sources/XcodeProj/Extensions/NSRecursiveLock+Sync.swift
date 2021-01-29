import Foundation

extension NSRecursiveLock {
    func whileLocked<T>(closure: () -> T) -> T {
        lock()
        defer {
            unlock()
        }
        let value = closure()
        return value
    }
}
