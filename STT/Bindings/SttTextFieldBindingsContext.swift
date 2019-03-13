//
//  SttTextFieldBindingContext.swift
//  STT
//
//  Created by Peter Standret on 2/7/19.
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
import RxSwift
import UIKit

public class SttTextFieldBindingContext<TViewController: AnyObject>: SttGenericBindingContext<TViewController, String?> {
    
    private let handler: SttHandlerTextField
    private var forProperty: SttTypeActionTextField?
    private var lazyWriterApply: ((String?) -> Void)!
    
    private var command: SttCommandType!
    
    weak private var target: Dynamic<String?>!
    unowned private var textField: UITextField
    
    internal init (viewController: TViewController, handler: SttHandlerTextField, textField: UITextField) {
        self.handler = handler
        self.textField = textField
        
        super.init(vc: viewController)
    }
    
    // MARK: - to
    
    @discardableResult
    override public func to<TValue>(_ value: Dynamic<TValue>) -> SttGenericBindingContext<TViewController, String?> {
        lazyWriterApply = { value.value = $0 as! TValue }
        return super.to(value)
    }
    
    @discardableResult
    public func to(_ value: SttCommandType) -> SttTextFieldBindingContext {
        self.command = value
        
        return self
    }
    
    // MARK: - forTarget
    
    @discardableResult
    public func forTarget(_ value: SttTypeActionTextField) -> SttTextFieldBindingContext {
        self.forProperty = value
        
        return self
    }

    // MARK: - applier
    
    override public func apply() {

        if let forProperty = forProperty, forProperty != .editing {
            bindSpecial()
        }
        else {
            bindEditing()
        }
    }
 
    private func bindSpecial() {
        handler.addTarget(type: forProperty!, delegate: self,
                          handler: { (d,_) in d.command.execute(parametr: d.parametr) })

    }

    private func bindEditing() {
        switch bindMode {
        case .write, .twoWayListener, .twoWayBind:
            handler.addTarget(type: SttTypeActionTextField.editing, delegate: self,
                              handler: {
                                let value = $0.converter != nil ? $0.converter?.convertBack(value: $1.text, parametr: $0.parametr) : $1.text
                                if let cvalue = value as? String {
                                    $0.lazyWriterApply(cvalue)
                                }
                                else {
                                    fatalError("Incorrect type, expected String?")
                                }
            }, textField: textField)
        default: break
        }
        
        super.forProperty({ [unowned self] (_, value) in
            let cvalue = self.converter != nil ? self.converter?.convert(value: value, parametr: self.parametr) : value
            if let _cvalue = cvalue as? String {
                self.textField.text = _cvalue
            }
            else {
                fatalError("Incorrect type, expected String?")
            }
        })

        switch bindMode {

        case .readListener, .twoWayListener:
            super.apply()
        case .readBind, .twoWayBind:
            super.apply()
        default: break
        }
    }
}

// MARK: - custom operator

@discardableResult
public func => <TViewController>(left: SttTextFieldBindingContext<TViewController>,
                                      right: SttTypeActionTextField) -> SttTextFieldBindingContext<TViewController> {
    return left.forTarget(right)
}

@discardableResult
public func ->> <TViewController>(left: SttTextFieldBindingContext<TViewController>,
                                       right: Dynamic<String?>) -> SttGenericBindingContext<TViewController, String?> {
    return left.withMode(.write).to(right)
}

@discardableResult
public func ->> <TViewController>(left: SttTextFieldBindingContext<TViewController>,
                                       right: SttCommandType) -> SttTextFieldBindingContext<TViewController> {
    return left.to(right)
}

@discardableResult
public func <->> <TViewController>(left: SttTextFieldBindingContext<TViewController>,
                                        right: Dynamic<String?>) -> SttGenericBindingContext<TViewController, String?> {
    return left.withMode(.twoWayListener).to(right)
}

@discardableResult
public func <<->> <TViewController>(left: SttTextFieldBindingContext<TViewController>,
                                         right: Dynamic<String?>) -> SttGenericBindingContext<TViewController, String?> {
    return left.withMode(.twoWayBind).to(right)
}
