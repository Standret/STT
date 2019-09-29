//
//  ControlPropertyContext.swift
//  STT
//
//  Created by Peter Standret on 9/22/19.
//  Copyright © 2019 standret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class ControlPropertyContext<Element: Equatable>: BindingContextType {
    
    private let property: ControlProperty<Element>
    private var bindingMode: BindingMode = .twoWayBind
    
    private var innerContext: BindingContextType?
    private var lazyApplier: Applier!
    
    init(_ property: ControlProperty<Element>) {
        self.property = property
    }
    
    /**
     Add to context converter
     
     - Important:
     
     Type on binding function and result of converter have to have the same type.
     
     Also, the type of dynamic property and type of converter's parameter have to have the same type.
     
     Otherwise program throw faralError
     
     ### Usage Example: ###
     ````
     set.bind(String.self).forProperty { $0.viewElement.property = $1 }
     .to(dynamicProperty)
     .withConverter(Converter.self)
     
     ````
     */
    @discardableResult
    open func withConverter<Converter: ConverterType>(_ converter: Converter, parameter: Any? = nil)
        -> ControlPropertyContext<Converter.TIn>
        where Converter.TOut == Element, Converter.TIn: Equatable {
            
            let newProperty = ControlProperty<Converter.TIn>.init(
                values: self.property.map({ converter.convertBack(value: $0, parameter: parameter) }),
                valueSink: Binder<Converter.TIn>.init(self, binding: { $0.property.onNext(converter.convert(value: $1, parameter: parameter)) })
            )
            
            lazyApplier = { return Disposables.create() }
            
            let context = ControlPropertyContext<Converter.TIn>(newProperty)
            context.bindingMode = self.bindingMode
            innerContext = context
            
            return context
    }
    
    /**
     Add to context Dynamic property for handler
     
     ### Usage Example: ###
     ````
     set.bind(String.self).forProperty { $0.viewElement.property = $1 }
     .to(dynamicProperty)
     
     ````
     */
    @discardableResult
    public func to(_ value: Dynamic<Element>) -> BindingContextType {
        
        lazyApplier = { [unowned self] in
            
            var readDisposable: Disposable? = nil
            var writeDisposable: Disposable? = nil
            
            // from dynamic to control property
            switch self.bindingMode {
            case .readBind, .twoWayBind:
                readDisposable = value.bind({ [unowned self] in self.property.onNext($0) })
            case .readListener, .twoWayListener:
                readDisposable = value.addListener({ [unowned self] in self.property.onNext($0) })
            default: break
            }
            
            switch self.bindingMode {
            case .twoWayBind, .twoWayListener, .write:
                writeDisposable = self.property.filter({ $0 != value.value })
                    .subscribe(onNext: { value.value = $0 })
            default: break
            }
            
            if let readDisposable = readDisposable, let writeDisposable = writeDisposable {
                return Disposables.create(readDisposable, writeDisposable)
            }
            
            return readDisposable == nil ? writeDisposable! : readDisposable!
        }
        
        return self
    }
    
    /**
     Add to context binding mode
     
     - Important:
     By default you should not call this method in most of cases.
     For view interactive components is .twoWayBind
     For not interactive (label) is readBind
     
     ### Usage Example: ###
     ````
     set.bind(String.self).forProperty { $0.viewElement.property = $1 }
     .to(dynamicProperty)
     .withMode(.listener)
     
     ````
     */
    @discardableResult
    public func withMode(_ mode: BindingMode) -> ControlPropertyContext<Element> {
        self.bindingMode = mode
        
        return self
    }
    
    @discardableResult
    public func apply() -> Disposable {
        
        if let disp = innerContext?.apply() {
            return Disposables.create(disp, lazyApplier())
        }
        
        return lazyApplier()
    }
}
