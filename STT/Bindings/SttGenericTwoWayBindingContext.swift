//
//  SttGenericTwoWayBindingContext.swift
//  STT
//
//  Created by Peter Standret on 3/18/19.
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

open class SttGenericTwoWayBindingContext<TViewController: AnyObject, TProperty>: SttGenericBindingContext<TViewController, TProperty> {
    
    internal var canBindSpecial: Bool { return false }
    
    private var lazyWriterApply: ((TProperty) -> Void)!
    
    internal init (viewController: TViewController) {
        
        super.init(vc: viewController)
        super.withMode(.twoWayBind)
    }
    
    // MARK: - to
    
    @discardableResult
    override open func to<TValue>(_ value: Dynamic<TValue>) -> SttGenericBindingContext<TViewController, TProperty> {
        lazyWriterApply = { value.value = $0 as! TValue }
        return super.to(value)
    }
    
    @discardableResult
    override open func to(_ command: SttCommandType) -> SttGenericBindingContext<TViewController, TProperty> {
        lazyWriterApply = { command.execute(parametr: $0) }
        
        return super.to(command)
    }
    
    override open func apply() {
        
        if canBindSpecial {
            bindSpecial()
        }
        else {
            bindEditing()
        }
    }
    
    open func bindSpecial() { notImplementException() }
    
    open func bindWriting() { notImplementException() }
    open func bindForProperty(_ value: TProperty) { notImplementException() }
    
    private func bindEditing() {
        switch bindMode {
        case .write, .twoWayListener, .twoWayBind:
            bindWriting()
        default: break
        }
        
        super.forProperty({ [unowned self] (_, value) in
            self.bindForProperty(value)
        })
        
        if bindMode != .write {
            super.apply()
        }
    }
    
    public func convertBackValue<TValue>(_ value: TValue) -> TValue {
        
        if let _converter = converter {
            if let cvalue = _converter.convertBack(value: value, parametr: parametr) as? TValue {
                return cvalue
            }
            else {
                fatalError("Expected type is \(type(of: TValue.self))")
            }
        }
        
        return value
    }
    
    public func convertValue<TValue>(_ value: TValue) -> TProperty {
        
        if let _converter = converter {
            if let cvalue = _converter.convert(value: value, parametr: parametr) as? TProperty {
                return cvalue
            }
            else {
                fatalError("Expected type is \(type(of: TProperty.self))")
            }
        }
        
        return value as! TProperty // TODO add handler
    }
}
