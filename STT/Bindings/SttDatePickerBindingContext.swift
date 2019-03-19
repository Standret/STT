//
//  SttDatePickerBindingContext.swift
//  STT
//
//  Created by Peter Standret on 3/18/19.
//  Copyright © 2019 standret. All rights reserved.
//

import Foundation
import UIKit

public class SttDatePickerBindingContext<TViewController: AnyObject>: SttGenericTwoWayBindingContext<TViewController, Date> {
    
    private var lazyWriterApply: ((Date) -> Void)!
    
    private let handler: SttHandlerDatePicker
    private var forTarget: SttActionDatePicker?
    
    weak private var target: Dynamic<String?>!
    unowned private var datePicker: UIDatePicker
    
    internal init (viewController: TViewController, handler: SttHandlerDatePicker, datePicker: UIDatePicker) {
        self.handler = handler
        self.datePicker = datePicker
        
        super.init(viewController: viewController)
        super.withMode(.twoWayBind)
    }
    
    @discardableResult
    override public func to<TValue>(_ value: Dynamic<TValue>) -> SttGenericBindingContext<TViewController, Date> {
        lazyWriterApply = { value.value = $0 as! TValue }
        return super.to(value)
    }
    
    override public func to(_ command: SttCommandType) -> SttGenericBindingContext<TViewController, Date> {
        lazyWriterApply = { command.execute(parametr: $0) }
        return super.to(command)
    }
    
    // MARK: - forTarget
    
    @discardableResult
    public func forTarget(_ value: SttActionDatePicker) -> SttDatePickerBindingContext {
        self.forTarget = value
        
        return self
    }
    
    // MARK: - applier
    
    open override func bindSpecial() {
        handler.addTarget(type: forTarget!, delegate: self,
                          handler: { (d,_) in d.command.execute(parametr: d.parametr) })
        
    }
    
    override public func bindWriting() {
        handler.addTarget(type: .valueChanged, delegate: self,
                          handler: { $0.lazyWriterApply(super.convertBackValue($1.date)) })
    }
    
    override public func bindForProperty(_ value: Date) {
        self.datePicker.date = value
    }
}
