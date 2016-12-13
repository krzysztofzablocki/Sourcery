//
//  main.swift
//  Insanity
//
//  Created by Krzysztof Zablocki on 09/12/2016.
//  Copyright © 2016 Pixle. All rights reserved.
//

import Foundation
import Commander
import PathKit

extension Path: ArgumentConvertible {
    public init(parser: ArgumentParser) throws {
        if let path = parser.shift() {
            self.init(path)
        } else {
            throw ArgumentError.missingValue(argument: nil)
        }
    }
}

fileprivate enum Validators {
    static func isReadable(path: Path) -> Path {
        if !path.isReadable {
            print("'\(path)' does not exist or is not readable.")
            exit(1)
        }

        return path
    }

    static func isFileOrDirectory(path: Path) -> Path {
        _ = isReadable(path: path)

        if !(path.isDirectory || path.isFile) {
            print("'\(path)' isn't a directory or proper file.")
            exit(2)
        }

        return path
    }
}

/// File path, can't be created with directory path.
public struct FilePath {
    public let path: Path
    public init?(path: Path) {
        guard path.isFile else {
            return nil
        }

        self.path = path
    }
}

func runCLI() {
    let version = "0.2.2"

    command(
        Flag("watch",
             flag: "w",
             description: "Watch template for changes and regenerate as needed. Only works with specific template path (not directory)."),
        Flag("verbose",
             flag: "v",
             description: "Turn on verbose logging for ignored entities"),
        Argument<Path>("source", description: "Path to a source swift files", validator: Validators.isFileOrDirectory),
        Argument<Path>("templates", description: "Path to templates. File or Directory≥", validator: Validators.isFileOrDirectory),
        Argument<Path>("output", description: "Path to output. File or Directory.")
    ) { watcherEnabled, verboseLogging, source, template, output in
        do {

            guard watcherEnabled else {
                return try Insanity(version: version, verbose: verboseLogging).processFiles(source, usingTemplates: template, output: output)
            }

            guard let onlySingleTemplate = FilePath(path: template) else {
                print("'\(template)' isn't a single template file. In watch enabled mode only a single file can be used.")
                exit(3)
            }

            if let _ = try Insanity(version: version, verbose: verboseLogging).processFiles(source, usingTemplates: onlySingleTemplate, output: output, watcherEnabled: watcherEnabled) {
                RunLoop.current.run()
            }
        } catch {
            print(error)
            exit(4)
        }
        }.run(version)
}

if NSClassFromString("XCTest") == nil {
    runCLI()
} else {
    //! Need to run something for tests to work
    final class TestApplicationController: NSObject, NSApplicationDelegate {
        let window =   NSWindow()

        func applicationDidFinishLaunching(aNotification: NSNotification) {
            window.setFrame(CGRect(x: 0, y: 0, width: 0, height: 0), display: false)
            window.makeKeyAndOrderFront(self)
        }

        func applicationWillTerminate(aNotification: NSNotification) {
        }

    }

    autoreleasepool { () -> () in
        let app =   NSApplication.shared()
        let controller =   TestApplicationController()

        app.delegate   = controller
        app.run()
    }
}
