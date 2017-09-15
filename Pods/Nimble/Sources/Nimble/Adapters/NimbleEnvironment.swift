import Dispatch
import Foundation

/// "Global" state of Nimble is stored here. Only DSL functions should access / be aware of this
/// class' existence
internal class NimbleEnvironment {
    static var activeInstance: NimbleEnvironment {
        get {
            let env = Thread.current.threadDictionary["NimbleEnvironment"]
            if let env = env as? NimbleEnvironment {
                return env
            } else {
                let newEnv = NimbleEnvironment()
                self.activeInstance = newEnv
                return newEnv
            }
        }
        set {
            Thread.current.threadDictionary["NimbleEnvironment"] = newValue
        }
    }

    // TODO: eventually migrate the global to this environment value
    var assertionHandler: AssertionHandler {
        get { return NimbleAssertionHandler }
        set { NimbleAssertionHandler = newValue }
    }

    var suppressTVOSAssertionWarning: Bool = false
    var awaiter: Awaiter

    init() {
        let timeoutQueue: DispatchQueue
        if #available(OSX 10.10, *) {
            timeoutQueue = DispatchQueue.global(qos: .userInitiated)
        } else {
            timeoutQueue = DispatchQueue.global(priority: .high)
        }

        awaiter = Awaiter(
            waitLock: AssertionWaitLock(),
            asyncQueue: .main,
            timeoutQueue: timeoutQueue)
    }
}
