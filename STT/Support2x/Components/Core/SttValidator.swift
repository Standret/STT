//
//  SttBaseValidator.swift
//  STT
//
//  Created by Peter Standret on 2/6/19.
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

open class SttValidator: SttValidatorType {
    
    public var name: String
    
    public var customIncorrectError: String?
    
    public var isRequired: Bool
    public var regexPattern: String?
    
    public var min: Int
    public var max: Int
    
    open var validationError: String { return try! getValidationError(of: validationResult)}
    open var validationResult: SttValidationResult = .empty
    
    public required init (name: String,
          isRequired: Bool = false,
          regexPattern: String? = nil,
          min: Int = Int.min, max: Int = Int.max,
          customIncorrectError: String? = nil) {
        
        self.name = name
        
        self.customIncorrectError = customIncorrectError
        
        self.isRequired = isRequired
        self.regexPattern = regexPattern
        
        self.min = min
        self.max = max
        
        validationResult = isRequired ? .empty : .ok
    }
    
    open func validate(object: String?, parametr: Any?) -> SttValidationResult {
        
        var result: SttValidationResult = .ok
        
        do {
            if String.isEmpty(object) {
                result = isRequired ? .empty : .ok
            }
            else if (object! as NSString).length < min {
                result = .toShort
            }
            else if (object! as NSString).length > max {
                result = .toLong
            }
            else if let pattern = regexPattern {
                
                let nsObject = object! as NSString
                let regex = try NSRegularExpression(pattern: pattern)
                if regex.matches(in: object!, range: NSRange(location: 0, length: nsObject.length)).count != 1 {
                    result = .inCorrect
                }
                
            }
            else {
                result = .ok
            }
        }
        catch {
            SttLog.error(message: "error \(error) in validate \(object!)", key: "SttValidationObject")
            result = .inCorrect
        }
        
        validationResult = result
        return result
    }
    
    open func getValidationError(of validationResult: SttValidationResult) throws -> String {
        
        var result: String!
        
        switch validationResult {
            
        case .ok: result = ""
        case .inCorrect: result = customIncorrectError ?? "\(name) is incorrect."
        case .toShort: result = "\(name) must contain at least \(min) characters long."
        case .toLong: result = "\(name) must contain at most \(max) characters long."
        case .empty: result = "\(name) is required."
        default: throw ValidatorError.unsupportedResultType
            
        }
        
        return result
    }
}
