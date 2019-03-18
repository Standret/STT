//
//  GenericBindingContext.swift
//  STT
//
//  Created by Peter Standret on 2/8/19.
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

/**
 An abstraction which can use for all possible bindings
 
 - REMARK:
 You should not create this class directly. Binding set create and provide it for you
 
 */
public class SttGenericBindingContext<TViewController: AnyObject, TProperty>: SttBindingContextType {
    
    public typealias PropertySetter = (_ vc: TViewController, _ property: TProperty) -> Void
    
    internal var bindMode = SttBindingMode.readBind
    
    private var lazyApply: (() -> Void)!
    private var lazyDispose: (() -> Void)!
    
    private(set) var setter: PropertySetter!
    private(set) var parametr: Any?
    private(set) var command: SttCommandType!

    
    private(set) var converter: SttConverterType?
    
    unowned let vc: TViewController
    
    internal init (vc: TViewController) {
        self.vc = vc
    }
    
    /**
     Add to context handler which call when dynamic property change
     
     - Parameter setter: Closure with 2 parameters property with safe point on view and new parametr
     
     ### Usage Example: ###
     ````
     set.bind(String.self).forProperty { $0.viewElement.property = $1 }
     
     ````
     */
    @discardableResult
    public func forProperty(_ setter: @escaping PropertySetter) -> SttGenericBindingContext<TViewController, TProperty> {
        self.setter = setter
        
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
    public func to<TValue>(_ value: Dynamic<TValue>) -> SttGenericBindingContext<TViewController, TProperty> {
        
        lazyApply = { [unowned self] in
            switch self.bindMode {
            case .readBind, .twoWayBind:
                value.bind { [unowned self] in
                    let value = self.converter != nil ? self.converter?.convert(value: $0, parametr: self.parametr) : $0
                    self.setter(self.vc, value as! TProperty)
                }
            case .readListener, .twoWayListener:
                value.addListener { [unowned self] in
                    let value = self.converter != nil ? self.converter?.convert(value: $0, parametr: self.parametr) : $0
                    self.setter(self.vc, value as! TProperty)
                }
            default:
                fatalError("incorrect type")
            }
        }
        
        lazyDispose = { value.dispose() }
        
        return self
    }
    
    @discardableResult
    public func to(_ value: SttCommandType) -> SttGenericBindingContext<TViewController, TProperty> {
        self.command = value
        
        return self
    }
    
    /**
     Add to context binding mode
     
     - Important:
     By default use bind mode so you should not call this method in most of cases
     
     ### Usage Example: ###
     ````
     set.bind(String.self).forProperty { $0.viewElement.property = $1 }
     .to(dynamicProperty)
     .withMode(.listener)
     
     ````
     */
    @discardableResult
    public func withMode(_ mode: SttBindingMode) -> SttGenericBindingContext<TViewController, TProperty> {
        self.bindMode = mode
        
        return self
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
    public func withConverter<T: SttConverterType>(_ _: T.Type) -> SttGenericBindingContext<TViewController, TProperty> {
        self.converter = T()
        
        return self
    }
    
    /**
     Add to context parameters. By default use as converter's parameter
     
     - This parametr pass as
     
     ### Usage Example: ###
     ````
     set.bind(String.self).forProperty { $0.viewElement.property = $1 }
     .to(dynamicProperty)
     .withConverter(Converter.self)
     .withCommandParametr(2319)
     
     ````
     */
    @discardableResult
    public func withCommandParametr(_ parametr: Any) -> SttGenericBindingContext<TViewController, TProperty> {
        self.parametr = parametr
        
        return self
    }
    
    /**
     apply binding context
     
     ## IMPORTANT ##
     
     Do not call this method directly!
     Binding set call this method for you
     
     */
    public func apply() {
        
        lazyApply?()
    }
    
    deinit {
        lazyDispose?()
    }
}

// MARK: - custom operator

/**
 
 Custom operators
 Second way to write bindings
 
 For more information look at our documentation on github
 
 UPS :\ Something missing
 If you see this message just write me. Prter Standret
 
 */

@discardableResult
public func => <TViewController, TProperty>(left: SttGenericBindingContext<TViewController, TProperty>,
                                     right: @escaping (TViewController, TProperty) -> Void) -> SttGenericBindingContext<TViewController, TProperty> {
    return left.forProperty(right)
}

@discardableResult
public func <- <TViewController, TProperty, TTarget>(left: SttGenericBindingContext<TViewController, TProperty>,
                                              right: Dynamic<TTarget>) -> SttGenericBindingContext<TViewController, TProperty> {
    return left.to(right).withMode(.readListener)
}

@discardableResult
public func <<- <TViewController, TProperty, TTarget>(left: SttGenericBindingContext<TViewController, TProperty>,
                                               right: Dynamic<TTarget>) -> SttGenericBindingContext<TViewController, TProperty> {
    return left.to(right).withMode(.readBind)
}

@discardableResult
public func ->> <TViewController, TProperty, TTarget>(left: SttGenericBindingContext<TViewController, TProperty>,
                                                      right: Dynamic<TTarget>) -> SttGenericBindingContext<TViewController, TProperty> {
    return left.to(right).withMode(.write)
}

@discardableResult
public func ->> <TViewController, TProperty>(left: SttGenericBindingContext<TViewController, TProperty>,
                                                      right: SttCommandType) -> SttGenericBindingContext<TViewController, TProperty> {
    return left.to(right)
}

@discardableResult
public func <->> <TViewController, TProperty, TTarget>(left: SttGenericBindingContext<TViewController, TProperty>,
                                                      right: Dynamic<TTarget>) -> SttGenericBindingContext<TViewController, TProperty> {
    return left.to(right).withMode(.twoWayListener)
}

@discardableResult
public func <<->> <TViewController, TProperty, TTarget>(left: SttGenericBindingContext<TViewController, TProperty>,
                                                      right: Dynamic<TTarget>) -> SttGenericBindingContext<TViewController, TProperty> {
    return left.to(right).withMode(.twoWayBind)
}


@discardableResult
public func >-< <TViewController, TProperty, T: SttConverterType>(left: SttGenericBindingContext<TViewController, TProperty>,
                                                           right: T.Type) -> SttGenericBindingContext<TViewController, TProperty> {
    return left.withConverter(T.self)
}

@discardableResult
public func -< <TViewController, TProperty>(left: SttGenericBindingContext<TViewController, TProperty> ,
                                     right: Any) -> SttGenericBindingContext<TViewController, TProperty> {
    return left.withCommandParametr(right)
}
