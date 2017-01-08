//
//  main.swift
//  Sourcery
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

struct CustomArguments: ArgumentConvertible {
    let arguments: Annotations

    init(parser: ArgumentParser) throws {
        guard let args = try parser.shiftValueForOption("args") else {
            self.arguments = Annotations()
            return
        }

        self.arguments = AnnotationsParser.parse(line: args)
    }

    var description: String {
        return arguments.description
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

func runCLI() {
    command(
        Flag("watch",
             flag: "w",
             description: "Watch template for changes and regenerate as needed."),
        Flag("verbose",
             flag: "v",
             description: "Turn on verbose logging for ignored entities"),
        Argument<Path>("source", description: "Path to a source swift files", validator: Validators.isFileOrDirectory),
        Argument<Path>("templates", description: "Path to templates. File or Directory.", validator: Validators.isFileOrDirectory),
        Argument<Path>("output", description: "Path to output. File or Directory."),
        Argument<CustomArguments>("args", description: "Custom values to pass to templates.")
    ) { watcherEnabled, verboseLogging, source, template, output, args in
        do {
            let start = CFAbsoluteTimeGetCurrent()
            if let keepAlive = try Sourcery(verbose: verboseLogging, arguments: args.arguments).processFiles(source, usingTemplates: template, output: output, watcherEnabled: watcherEnabled) {
                RunLoop.current.run()
                _ = keepAlive
            } else {
                print("Processing time \(CFAbsoluteTimeGetCurrent() - start) seconds")
            }
        } catch {
            print(error)
            exit(4)
        }
        }.run(Sourcery.version)
}

public var inUnitTests = NSClassFromString("XCTest") != nil

#if os(macOS)
import AppKit

if !inUnitTests {
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

    autoreleasepool { () -> Void in
        let app =   NSApplication.shared()
        let controller =   TestApplicationController()

        app.delegate   = controller
        app.run()
    }
}
#endif
