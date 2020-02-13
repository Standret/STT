//
//  SttSearchBarBindingContext.swift
//  STT
//
//  Created by Peter Standret on 4/25/19.
//  Copyright © 2019 standret. All rights reserved.
//

import Foundation
import UIKit

public class SttSearchBarBindingContext<TViewController: AnyObject>: SttGenericTwoWayBindingContext<TViewController, String?> {
    
    override var canBindSpecial: Bool { return forTarget != nil }
    
    private let handler: SttHanlderSearchBar
    private var forTarget: SttActionSearchBar?
    private var lazyWriterApply: ((String?) -> Void)!
    
    weak private var target: Dynamic<String?>!
    unowned private var searchBar: UISearchBar
    
    internal init (viewController: TViewController, handler: SttHanlderSearchBar, searchBar: UISearchBar) {
        self.handler = handler
        self.searchBar = searchBar
        
        super.init(viewController: viewController)
        super.withMode(.twoWayBind)
    }
    
    @discardableResult
    override public func to<TValue>(_ value: Dynamic<TValue>) -> SttGenericBindingContext<TViewController, String?> {
        lazyWriterApply = { value.value = $0 as! TValue }
        return super.to(value)
    }
    
    @discardableResult
    override public func to<TValue>(_ value: Dynamic<TValue?>) -> SttGenericBindingContext<TViewController, String?> {
        lazyWriterApply = { value.value = $0 as? TValue }
        return super.to(value)
    }
    
    @discardableResult
    override public func to(_ command: SttCommandType) -> SttGenericBindingContext<TViewController, String?> {
        lazyWriterApply = { command.execute(parametr: $0) }
        return super.to(command)
    }
    
    // MARK: - forTarget
    
    @discardableResult
    public func forTarget(_ value: SttActionSearchBar) -> SttSearchBarBindingContext {
        self.forTarget = value
        
        return self
    }
    
    // MARK: - applier
    
    override open func bindSpecial() {
        handler.addTarget(type: forTarget!, delegate: self,
                          handler: { (d,_) in d.command.execute(parametr: d.parametr) })
        
    }
    
    override open func bindWriting() {
        handler.addTarget(type: SttActionSearchBar.editing, delegate: self,
                          handler: { $0.lazyWriterApply(super.convertBackValue($1.text)) })
    }
    
    override open func bindForProperty(_ value: String?) {
        self.searchBar.text = value
    }
}
