//
//  SttGenericTwoWayBindingContext.swift
//  STT
//
//  Created by Peter Standret on 3/18/19.
//  Copyright © 2019 standret. All rights reserved.
//

import Foundation

public class SttGenericTwoWayBindingContext<TViewController: AnyObject, TProperty>: SttGenericBindingContext<TViewController, TProperty> {
    
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
        
        return self
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
    
    public func convertValue<TValue>(_ value: TValue) -> TValue {
        
        if let _converter = converter {
            if let cvalue = _converter.convert(value: value, parametr: parametr) as? TValue {
                return cvalue
            }
            else {
                fatalError("Expected type is \(type(of: TValue.self))")
            }
        }
        
        return value
    }
}
