import Dispatch
import Foundation

private enum ErrorResult {
    case exception(NSException)
    case error(Error)
    case none
}

/// Only classes, protocols, methods, properties, and subscript declarations can be
/// bridges to Objective-C via the @objc keyword. This class encapsulates callback-style
/// asynchronous waiting logic so that it may be called from Objective-C and Swift.
internal class NMBWait: NSObject {
    internal class func until(
        timeout: TimeInterval,
        file: FileString = #file,
        line: UInt = #line,
        action: @escaping (@escaping () -> Void) -> Void) {
            return throwableUntil(timeout: timeout, file: file, line: line) { done in
                action(done)
            }
    }

    // Using a throwable closure makes this method not objc compatible.
    internal class func throwableUntil(
        timeout: TimeInterval,
        file: FileString = #file,
        line: UInt = #line,
        action: @escaping (@escaping () -> Void) throws -> Void) {
            let awaiter = NimbleEnvironment.activeInstance.awaiter
            let leeway = timeout / 2.0
        let result = awaiter.performBlock(file: file, line: line) { (done: @escaping (ErrorResult) -> Void) throws -> Void in
                DispatchQueue.main.async {
                    let capture = NMBExceptionCapture(
                        handler: ({ exception in
                            done(.exception(exception))
                        }),
                        finally: ({ })
                    )
                    capture.tryBlock {
                        do {
                            try action {
                                done(.none)
                            }
                        } catch let e {
                            done(.error(e))
                        }
                    }
                }
            }.timeout(timeout, forcefullyAbortTimeout: leeway).wait("waitUntil(...)", file: file, line: line)

            switch result {
            case .incomplete: internalError("Reached .incomplete state for waitUntil(...).")
            case .blockedRunLoop:
                fail(blockedRunLoopErrorMessageFor("-waitUntil()", leeway: leeway),
                    file: file, line: line)
            case .timedOut:
                let pluralize = (timeout == 1 ? "" : "s")
                fail("Waited more than \(timeout) second\(pluralize)", file: file, line: line)
            case let .raisedException(exception):
                fail("Unexpected exception raised: \(exception)")
            case let .errorThrown(error):
                fail("Unexpected error thrown: \(error)")
            case .completed(.exception(let exception)):
                fail("Unexpected exception raised: \(exception)")
            case .completed(.error(let error)):
                fail("Unexpected error thrown: \(error)")
            case .completed(.none): // success
                break
            }
    }

    #if SWIFT_PACKAGE
    internal class func until(_ file: FileString = #file, line: UInt = #line, action: @escaping (() -> Void) -> Void) {
        until(timeout: 1, file: file, line: line, action: action)
    }
    #else
    @objc(untilFile:line:action:)
    internal class func until(_ file: FileString = #file, line: UInt = #line, action: @escaping (() -> Void) -> Void) {
        until(timeout: 1, file: file, line: line, action: action)
    }
    #endif
}

internal func blockedRunLoopErrorMessageFor(_ fnName: String, leeway: TimeInterval) -> String {
    return "\(fnName) timed out but was unable to run the timeout handler because the main thread is unresponsive (\(leeway) seconds is allow after the wait times out). Conditions that may cause this include processing blocking IO on the main thread, calls to sleep(), deadlocks, and synchronous IPC. Nimble forcefully stopped run loop which may cause future failures in test run."
}

/// Wait asynchronously until the done closure is called or the timeout has been reached.
///
/// @discussion
/// Call the done() closure to indicate the waiting has completed.
/// 
/// This function manages the main run loop (`NSRunLoop.mainRunLoop()`) while this function
/// is executing. Any attempts to touch the run loop may cause non-deterministic behavior.
public func waitUntil(timeout: TimeInterval = 1, file: FileString = #file, line: UInt = #line, action: @escaping (@escaping () -> Void) -> Void) {
    NMBWait.until(timeout: timeout, file: file, line: line, action: action)
}
