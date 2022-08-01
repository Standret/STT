//
//  SttLog.swift
//  STT
//
//  Created by Peter Standret on 9/21/19.
//  Copyright © 2019 Peter Standret <pstandret@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

public protocol SttLogType {
    var destinations: SttLogLevel { get set }
    func log(_ closure: () -> Any?, level: SttLogLevel, functionName: String, fileName: String, lineNumber: Int)
}

public extension SttLogType {
    func verbose(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.log(closure, level: .verbose, functionName: String(functionName), fileName: String(fileName), lineNumber: lineNumber)
    }
    func debug(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.log(closure, level: .debug, functionName: String(functionName), fileName: String(fileName), lineNumber: lineNumber)
    }
    func info(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.log(closure, level: .info, functionName: String(functionName), fileName: String(fileName), lineNumber: lineNumber)
    }
    func notice(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.log(closure, level: .notice, functionName: String(functionName), fileName: String(fileName), lineNumber: lineNumber)
    }
    func warning(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.log(closure, level: .warning, functionName: String(functionName), fileName: String(fileName), lineNumber: lineNumber)
    }
    func error(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.log(closure, level: .error, functionName: String(functionName), fileName: String(fileName), lineNumber: lineNumber)
    }
    func alert(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.log(closure, level: .alert, functionName: String(functionName), fileName: String(fileName), lineNumber: lineNumber)
    }
    func emergency(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.log(closure, level: .emergency, functionName: String(functionName), fileName: String(fileName), lineNumber: lineNumber)
    }

    // deprecated
    @available(swift, obsoleted: 5.0)
    var logInSystem: Bool { false }

    @available(swift, obsoleted: 5.0, renamed: "verbose(_functionName:fileName:lineNumber:)")
    func trace(message: String, key: String) { }
    @available(swift, obsoleted: 5.0, renamed: "verbose(_functionName:fileName:lineNumber:)")
    func warning(message: String, key: String) { }
    @available(swift, obsoleted: 5.0, renamed: "verbose(_functionName:fileName:lineNumber:)")
    func error(message: String, key: String) { }
}

public enum SttLogLevel: Int, CaseIterable {
    case verbose
    case debug
    case info
    case notice
    case warning
    case error
    case severe // aka critical
    case alert
    case emergency
    case none

    public var description: String {
        switch self {
        case .verbose:
            return "Verbose"
        case .debug:
            return "Debug"
        case .info:
            return "Info"
        case .notice:
            return "Notice"
        case .warning:
            return "Warning"
        case .error:
            return "Error"
        case .severe:
            return "Severe"
        case .alert:
            return "Alert"
        case .emergency:
            return "Emergency"
        case .none:
            return "None"
        }
    }

    func isEnabledFor(level: SttLogLevel) -> Bool {
        level.rawValue >= self.rawValue
    }
}

open class SttLog: SttLogType {

    public static func register(logger: SttLogType) {
        shared = logger
    }
    
    public static var shared: SttLogType = SttLog()

    public var destinations: SttLogLevel = .verbose
    
    private init() { }

    public func log(_ closure: () -> Any?, level: SttLogLevel, functionName: String, fileName: String, lineNumber: Int) {
        guard destinations.isEnabledFor(level: level),
              let closureResult = closure() else {
                  return
              }
        let formatedFileName = fileName.split(separator: "/").last ?? ""
        NSLog("[\(level.description)] [\(threadName())] [\(formatedFileName):\(lineNumber)] \(functionName) > \(closureResult)")
    }

    private func threadName() -> String {
        var result: String
        if Thread.isMainThread {
            result = "main"
        }
        else {
            if let threadName = Thread.current.name, !threadName.isEmpty {
                result = threadName
            }
            else if let queueName = String(validatingUTF8: __dispatch_queue_get_label(nil)), !queueName.isEmpty {
                result = queueName
            }
            else {
                result = String(format: "[%p] ", Thread.current)
            }
        }
        return result
    }
}

fileprivate extension String {
    init(_ staticString: StaticString) {
        self = staticString.withUTF8Buffer {
            String(decoding: $0, as: UTF8.self)
        }
    }
}
