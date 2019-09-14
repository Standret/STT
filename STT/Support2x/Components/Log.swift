//
//  Log.swift
//  STT
//
//  Created by Peter Standret on 3/13/19.
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

internal class SttLogDateConverter: SttConverter<Date, String> {
    
    override func convert(value: Date, parametr: Any?) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MM-dd-yyyy HH:mm:ss:SSSS"
        
        return formatter.string(from: value)
    }
}

internal class DateConverter: SttConverter<Date, String> {
    
    override func convert(value: Date, parametr: Any?) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MM/dd/yyyy"
        
        return formatter.string(from: value)
    }
}

open class SttLog {
    
    public static var logInSystem = true
    
    open class func trace(message: String, key: String) {
        log(type: "trace", message: message, key: key)
    }
    open class func warning(message: String, key: String) {
        log(type: "warning", message: message, key: key)
    }
    open class func error(message: String, key: String) {
        log(type: "error", message: message, key: key)
    }
    
    fileprivate class func log(type: String, message: String, key: String) {
        
        if logInSystem {
            NSLog("<\(key)> \(message)")
        }
        else {
            print("[\(type)][\(SttLogDateConverter().convert(value: Date()))] <\(key)> \(message)")
        }
    }
}
