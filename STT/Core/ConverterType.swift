//
//  ConverterType.swift
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

public protocol ConverterType: AnyObject {
    
    init()
    
    func convert(value: Any?, parametr: Any?) -> Any
    func convertBack(value: Any?, parametr: Any?) -> Any
}

open class Converter<TIn, TOut>: ConverterType {
    
    public required init() { }
    
    public func convert(value: Any?, parametr: Any?) -> Any {
        return self.convert(value: value as! TIn, parametr: parametr)
    }
    
    public func convertBack(value: Any?, parametr: Any?) -> Any {
        return self.convertBack(value: value as! TOut, parametr: parametr)
    }
    
    open func convert(value: TIn, parametr: Any?) -> TOut {
        fatalError("should be implemented")
    }
    
    open func convertBack(value: TOut, parametr: Any?) -> TIn {
        fatalError("should be implemented")
    }
}

public extension Converter {
    
    func convert(value: TIn) -> TOut {
        return self.convert(value: value, parametr: nil)
    }
}
