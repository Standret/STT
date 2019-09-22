//
//  BinderContext.swift
//  STT
//
//  Created by Peter Standret on 9/22/19.
//  Copyright © 2019 standret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public typealias Applier = () -> Disposable
public class BinderContext<Element>: BindingContextType {
    
    private let binder: Binder<Element>
    private var bindingMode: BindingMode = .readBind
    
    private var lazyApplier: Applier!
    
    init(_ binder: Binder<Element>) {
        self.binder = binder
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
    open func withConverter<Converter: ConverterType>(_ converter: Converter)
        -> BinderContext<Converter.TIn> where Converter.TOut == Element {
            
            let converterBinder = Binder<Converter.TIn>.init(self) { (object, value) in
                self.binder.onNext(converter.convert(value: value))
            }
            let binderContext = BinderContext<Converter.TIn>(converterBinder)
            lazyApplier = binderContext.apply
            
            return binderContext
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
    public func to(_ value: Dynamic<Element>) -> BinderContext<Element> {
        
        lazyApplier = { [unowned self] in
            
            switch self.bindingMode {
            case .readBind, .twoWayBind:
                return value.bind({ [unowned self] value in self.binder.onNext(value) })
            case .readListener, .twoWayListener:
                return value.addListener({ [unowned self] value in self.binder.onNext(value) })
            default:
                fatalError("Incorrect type")
            }
        }
        
        return self
    }
    
    /**
     Add to context Dynamic property for handler
     
     ### Usage Example: ###
     ````
     set.bind(String.self).forProperty { $0.viewElement.property = $1 }
     .to(dynamicProperty)
     
     ````
     */
    public func to(_ value: Dynamic<Element?>, fallbackValue: Element) -> BinderContext<Element> {
        
        lazyApplier = { [unowned self] in
            
            switch self.bindingMode {
            case .readBind, .twoWayBind:
                return value.bind({ [unowned self] value in self.binder.onNext(value ?? fallbackValue) })
            case .readListener, .twoWayListener:
                return value.addListener({ [unowned self] value in self.binder.onNext(value ?? fallbackValue) })
            default:
                fatalError("Incorrect type")
            }
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
    public func withMode(_ mode: BindingMode) -> BinderContext<Element> {
        self.bindingMode = mode
        
        return self
    }
    
    @discardableResult
    public func apply() -> Disposable {
        return lazyApplier()
    }
}

public extension BinderContext where Element == String {
    
    /**
     Add to context Dynamic property for handler
     
     ### Usage Example: ###
     ````
     set.bind(String.self).forProperty { $0.viewElement.property = $1 }
     .to(dynamicProperty)
     
     ````
     */
    @discardableResult
    func to(_ value: Dynamic<Int>) -> BinderContext<Element> {
        
        lazyApplier = { [unowned self] in
            
            switch self.bindingMode {
            case .readBind, .twoWayBind:
                return value.bind({ [unowned self] value in self.binder.onNext(String(value)) })
            case .readListener, .twoWayListener:
                return value.addListener({ [unowned self] value in self.binder.onNext(String(value)) })
            default:
                fatalError("Incorrect type")
            }
        }
        
        return self
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
    func to(_ value: Dynamic<Int?>, fallbackValue: Int) -> BinderContext<Element> {
        
        lazyApplier = { [unowned self] in
            
            switch self.bindingMode {
            case .readBind, .twoWayBind:
                return value.bind({ [unowned self] value in self.binder.onNext(String(value ?? fallbackValue)) })
            case .readListener, .twoWayListener:
                return value.addListener({ [unowned self] value in self.binder.onNext(String(value ?? fallbackValue)) })
            default:
                fatalError("Incorrect type")
            }
        }
        
        return self
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
    func to(_ value: Dynamic<String?>, fallbackValue: String) -> BinderContext<Element> {
        
        lazyApplier = { [unowned self] in
            
            switch self.bindingMode {
            case .readBind, .twoWayBind:
                return value.bind({ [unowned self] value in self.binder.onNext(value ?? fallbackValue) })
            case .readListener, .twoWayListener:
                return value.addListener({ [unowned self] value in self.binder.onNext(value ?? fallbackValue) })
            default:
                fatalError("Incorrect type")
            }
        }
        
        return self
    }
}
