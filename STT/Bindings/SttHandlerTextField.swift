//
//  SttHandlerTextField.swift
//  STT
//
//  Created by Standret on 5/19/18.
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
import UIKit

public enum SttTypeActionTextField {
    case shouldReturn
    case didEndEditing, didStartEditing
    case editing
}

open class SttHandlerTextField: NSObject, UITextFieldDelegate {
    
    // private property
    private var handlers = [SttTypeActionTextField: [SttDelegatedCall<UITextField>]]()
    private var shouldHandlers = [SttTypeActionTextField: [(UITextField) -> Bool]]()

    // method for add target
    public var maxLength: Int?
    public init (_ textField: UITextField) {
        super.init()
        
        textField.addTarget(self, action: #selector(changing(_:)), for: .editingChanged)
        textField.addTarget(self, action: #selector(didEndEditing(_:)), for: .editingDidEnd)
        textField.addTarget(self, action: #selector(didStartEditing(_:)), for: .editingDidBegin)
    }
    
    public func addTarget<T: AnyObject>(type: SttTypeActionTextField, delegate: T, handler: @escaping (T, UITextField) -> Void) {
        
        handlers[type] = handlers[type] ?? [SttDelegatedCall<UITextField>]()
        handlers[type]!.append(SttDelegatedCall<UITextField>(to: delegate, with: handler))
    }
    
    public func addShouldReturnTarget<T: AnyObject>(type: SttTypeActionTextField, delegate: T, handler: @escaping (T, UITextField) -> Bool) {
        
        if type != .shouldReturn { fatalError("IncorrectTypes") }
        shouldHandlers[type] = shouldHandlers[type] ?? [(UITextField) -> Bool]()
        shouldHandlers[type]!.append({ [weak delegate] textField in
            
            if let _delegate = delegate {
                return handler(_delegate, textField)
            }
            
            return false
        })
    }
    
    @objc private func changing(_ textField: UITextField) {
        handlers[.editing]?.forEach({ $0.callback(textField) })
    }
    
    @objc private func didEndEditing(_ textField: UITextField) {
        handlers[.didEndEditing]?.forEach({ $0.callback(textField) })
    }
    
    @objc private func didStartEditing(_ textField: UITextField) {
        handlers[.didStartEditing]?.forEach({ $0.callback(textField) })
    }
    
    
    
    // implementation of protocol UITextFieldDelegate
    
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handlers[.shouldReturn]?.forEach({ $0.callback(textField) })
        return false
    }
    
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let max = maxLength {
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= max
        }
        
        return true        
    }
}


