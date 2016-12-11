//
//  Local.swift
//  KZFileWatchers
//
//  Created by Krzysztof Zabłocki on 05/08/16.
//
//

import Foundation

public extension FileWatcher {
    
    /**
     Watcher for local files, it uses content diffing.
     */
    public final class Local: FileWatcherProtocol {
        private typealias CancelBlock = () -> Void
        
        private enum State {
            case Started(source: DispatchSourceFileSystemObject, fileHandle: CInt, callback: FileWatcher.UpdateClosure, cancel: CancelBlock)
            case Stopped
        }
        
        private let path: String
        private let refreshInterval: TimeInterval
        private let queue: DispatchQueue
        
        private var state: State = .Stopped
        private var isProcessing: Bool = false
        private var cancelReload: CancelBlock?
        private var previousContent: Data?
        
        /**
         Initializes watcher to specified path.
         
         - parameter path:     Path of file to observe.
         - parameter refreshInterval: Refresh interval to use for updates.
         - parameter queue:    Queue to use for firing `onChange` callback.
         
         - note: By default it throttles to 60 FPS, some editors can generate stupid multiple saves that mess with file system e.g. Sublime with AutoSave plugin is a mess and generates different file sizes, this will limit wasted time trying to load faster than 60 FPS, and no one should even notice it's throttled.
         */
        public init(path: String, refreshInterval: TimeInterval = 1/60, queue: DispatchQueue = DispatchQueue.main) {
            self.path = path
            self.refreshInterval = refreshInterval
            self.queue = queue
        }
        
        /**
         Starts observing file changes.
         
         - throws: FileWatcher.Error
         */
        public func start(closure: @escaping FileWatcher.UpdateClosure) throws {
            guard case .Stopped = state else { throw Error.alreadyStarted }
            try startObserving(closure)
        }
        
        /**
         Stops observing file changes.
         */
        public func stop() throws {
            guard case let .Started(_, _, _, cancel) = state else { throw Error.alreadyStopped }
            cancelReload?()
            cancelReload = nil
            cancel()
            
            isProcessing = false
            state = .Stopped
        }
        
        deinit {
            if case .Started = state {
                _ = try? stop()
            }
        }
        
        private func startObserving(_ closure: @escaping FileWatcher.UpdateClosure) throws {
            let handle = open(path, O_EVTONLY)
            
            if handle == -1 {
                throw Error.failedToStart(reason: "Failed to open file")
            }
            
            let source = DispatchSource.makeFileSystemObjectSource(
                fileDescriptor: handle,
                eventMask: [.delete, .write, .extend, .attrib, .link, .rename, .revoke],
                queue: queue
            )
            
            let cancelBlock = {
                source.cancel()
            }
            
            source.setEventHandler {
                let flags = source.data
                
                if flags.contains(.delete) || flags.contains(.rename) {
                    _ = try? self.stop()
                    _ = try? self.startObserving(closure)
                    return
                }
                
                self.needsToReload()
            }
            
            source.setCancelHandler {
                close(handle)
            }
            
            source.resume()
            
            state = .Started(source: source, fileHandle: handle, callback: closure, cancel: cancelBlock)
            refresh()
        }
        
        private func needsToReload() {
            guard case .Started = state else { return }
            
            cancelReload?()
            cancelReload = throttle(after: refreshInterval) { self.refresh() }
        }
        
        /**
         Force refresh, can only be used if the watcher was started and it's not processing.
         */
        public func refresh() {
            guard case let .Started(_, _, closure, _) = state, isProcessing == false else { return }
            isProcessing = true
            
            let url = URL(fileURLWithPath: path)
            guard let content = try? Data(contentsOf: url, options: .uncached) else {
                isProcessing = false
                return
            }
            
            if content != previousContent {
                previousContent = content
                queue.async {
                    closure(.updated(data: content))
                }
            } else {
                queue.async {
                    closure(.noChanges)
                }
            }
            
            isProcessing = false
            cancelReload = nil
        }
        
        private func throttle(after: Double, action: @escaping () -> Void) -> CancelBlock {
            var isCancelled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + after) {
                if !isCancelled {
                    action()
                }
            }
            
            return {
                isCancelled = true
            }
        }
    }
    
}


public extension FileWatcher.Local {
    #if (arch(i386) || arch(x86_64)) && os(iOS)
    
    /**
     Returns username of OSX machine when running on simulator.
     
     - returns: Username (if available)
     */
    public class func simulatorOwnerUsername() -> String {
    //! running on simulator so just grab the name from home dir /Users/{username}/Library...
    let usernameComponents = NSHomeDirectory().components(separatedBy: "/")
    guard usernameComponents.count > 2 else { fatalError() }
    return usernameComponents[2]
    }
    #endif
}
