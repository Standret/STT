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
    
    public typealias ObserveClosure = (Element) -> Void
    
    private let property: Dynamic<Element>
    private var bindingMode: BindingMode = .readBind
    
    private var innerContext: BindingContextType?
    private var lazyApplier: Applier!
    
    init(_ property: Dynamic<Element>) {
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
        -> BinderContext<Converter.TOut> where Converter.TIn == Element {
            
            let newProperty = Dynamic(converter.convert(value: self.property.value, parameter: parameter))
            
            let binderContext = BinderContext<Converter.TOut>(newProperty)
            binderContext.bindingMode = self.bindingMode
            innerContext = binderContext
            
            lazyApplier = { [unowned self] in
                switch self.bindingMode {
                case .readBind, .twoWayBind:
                    return self.property.bind({ newProperty.value = converter.convert(value: $0, parameter: parameter) })
                case .readListener, .twoWayListener:
                    return self.property.addListener({ newProperty.value = converter.convert(value: $0, parameter: parameter) })
                default:
                    fatalError("Incorrect type")
                }
            }
            
            return binderContext
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
    open func withConverter<TOut>(_ converter: @escaping (Element) -> TOut)
        -> BinderContext<TOut> {
            
            let newProperty = Dynamic(converter(self.property.value))
            
            let binderContext = BinderContext<TOut>(newProperty)
            binderContext.bindingMode = self.bindingMode
            innerContext = binderContext
            
            lazyApplier = { [unowned self] in
                switch self.bindingMode {
                case .readBind, .twoWayBind:
                    return self.property.bind({ newProperty.value = converter($0) })
                case .readListener, .twoWayListener:
                    return self.property.addListener({ newProperty.value = converter( $0) })
                default:
                    fatalError("Incorrect type")
                }
            }
            
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
    public func to(_ binder: Binder<Element>) -> BindingContextType {
        
        lazyApplier = { [unowned self] in
            
            switch self.bindingMode {
            case .readBind, .twoWayBind:
                return self.property.bind(binder.onNext)
            case .readListener, .twoWayListener:
                return self.property.addListener(binder.onNext)
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
    public func to(_ binder: Binder<Element?>) -> BindingContextType {
        
        lazyApplier = { [unowned self] in
            
            switch self.bindingMode {
            case .readBind, .twoWayBind:
                return self.property.bind(binder.onNext)
            case .readListener, .twoWayListener:
                return self.property.addListener(binder.onNext)
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
    public func to(_ closure: @escaping ObserveClosure) -> BindingContextType {
        
        lazyApplier = { [unowned self] in
            
            switch self.bindingMode {
            case .readBind, .twoWayBind:
                return self.property.bind(closure)
            case .readListener, .twoWayListener:
                return self.property.addListener(closure)
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
        
        if let disp = innerContext?.apply() {
            return Disposables.create(disp, lazyApplier())
        }
        
        return lazyApplier()
    }
}

public extension BinderContext where Element == Int {
    
    /**
     Add to context Dynamic property for handler
     
     ### Usage Example: ###
     ````
     set.bind(String.self).forProperty { $0.viewElement.property = $1 }
     .to(dynamicProperty)
     
     ````
     */
    @discardableResult
    func to(_ binder: Binder<String>) -> BindingContextType {
        return self
            .withConverter({ String($0) })
            .to(binder)
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
    func to(_ label: UILabel) -> BindingContextType {
        return self.to(label.rx.text)
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
    func to(_ label: UILabel) -> BindingContextType {
        return self.to(label.rx.text)
    }
}

public extension BinderContext where Element == Bool {
    
    func withNegativeConverter() -> BinderContext<Element> {
        return self.withConverter({ !$0 })
    }
}
