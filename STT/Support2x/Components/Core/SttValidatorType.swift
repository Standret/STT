//
//  SttValidatorType.swift
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

/// Represent base of type for all validator
public protocol SttValidatorType {
    
    var name: String { get }
    
    var customIncorrectError: String? { get }
    
    var isRequired: Bool { get }
    var regexPattern: String? { get }
    
    var min: Int { get }
    var max: Int { get }
    
    init (name: String, isRequired: Bool, regexPattern: String?, min: Int, max: Int, customIncorrectError: String?)
    
    var validationError: String { get }
    var validationResult: SttValidationResult { get }
    
    @discardableResult
    func validate(object: String?, parametr: Any?) -> SttValidationResult
}

public extension SttValidatorType {
    
    var isError: Bool { return validationResult != .ok }
    
    @discardableResult
    func validate(object: String?, parametr: Any? = nil) -> SttValidationResult {
        return self.validate(object: object, parametr: parametr)
    }
}
