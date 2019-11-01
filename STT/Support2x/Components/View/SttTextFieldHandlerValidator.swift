//
//  TextFieldHandlerValidator.swift
//  STT
//
//  Created by Peter Standret on 2/14/19.
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

public class SttTextFieldHandlerValidator {
    
    private var onUpdateError: (() -> Void)!
    
    public init<T: Viewable>(delegate: T, inputBox: SttInputBox, handler: SttHandlerTextField, action: @escaping (T) -> Void) {
        var isError = false
        
        onUpdateError = {
            isError = inputBox.isError
        }
        
        handler.addTarget(type: .didStartEditing, delegate: delegate, handler: { (_,_) in isError = inputBox.isError })
        handler.addTarget(type: .editing, delegate: delegate,
                          handler: { (d,_) in
                            if isError {
                                action(d)
                            }
            })
    }
    
    @available(*, deprecated, message: "Will be remove in future release")
    public func updateError() {
        onUpdateError()
    }
}
