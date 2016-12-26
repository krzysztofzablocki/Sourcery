import Foundation

class Logger {
    let destination: URL
    lazy fileprivate var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"

        return formatter
    }()
    lazy fileprivate var fileHandle: FileHandle? = {
        let path = self.destination.path
        FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)

        do {
            let fileHandle = try FileHandle(forWritingTo: self.destination)
            print("Successfully logging to: \(path)")
            return fileHandle
        } catch let error as NSError {
            print("Serious error in logging: could not open path to log file. \(error).")
        }

        return nil
    }()

    init(destination: URL) {
        self.destination = destination
    }

    deinit {
        fileHandle?.closeFile()
    }

    func log(_ message: String, function: String = #function, file: String = #file, line: Int = #line) {
        let logMessage = stringRepresentation(message, function: function, file: file, line: line)

        printToConsole(logMessage)
        printToDestination(logMessage)
    }
}

private extension Logger {
    func stringRepresentation(_ message: String, function: String, file: String, line: Int) -> String {
        let dateString = dateFormatter.string(from: Date())

        let file = URL(fileURLWithPath: file).lastPathComponent
        return "\(dateString) [\(file):\(line)] \(function): \(message)\n"
    }

    func printToConsole(_ logMessage: String) {
        print(logMessage)
    }

    func printToDestination(_ logMessage: String) {
        if let data = logMessage.data(using: String.Encoding.utf8) {
            fileHandle?.write(data)
        } else {
            print("Serious error in logging: could not encode logged string into data.")
        }
    }
}
