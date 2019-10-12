//
//  BindingSet.swift
//  STT
//
//  Created by Peter Standret on 9/22/19.
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
import RxCocoa
import RxSwift
import UIKit

public enum BindingMode {
    case readListener
    case readBind
    case write
    case twoWayListener
    case twoWayBind
}

public protocol BindingContextType {
    @discardableResult
    func apply() -> Disposable
}

/**
 An abstraction of binding context. Give a target object with method for target binding elements on view,
 provide in target clouser safe property to target view controller.
 When all elements were binded user have to call aplly to accept all bindings.
 
 ### Usage Example: ###
 ````
 var set = BindingSet(parent: self)
 
 // all binding here
 
 set.apply()
 
 ````
 */
public class BindingSet<T: AnyObject>: BindingContextType {
    
    private unowned var parent: T
    
    private var sets = [BindingContextType]()
    private var disposable: Disposable?
    
    public init (_ parent: T) {
        self.parent = parent
    }
    
    public func bind<Element>(_ value: Dynamic<Element>) -> BinderContext<Element> {
        let context = BinderContext(value)
        sets.append(context)
        return context
    }
    
    public func bind<Element1, Element2>(
        _ value1: Dynamic<Element1>,
        _ value2: Dynamic<Element2>
        ) -> ValueCombiner<Element1, Element2> {
        
        let context = ValueCombiner(value1, value2)
        sets.append(context)
        return context
    }
    
    public func bind<Element1, Element2, Element3>(
        _ value1: Dynamic<Element1>,
        _ value2: Dynamic<Element2>,
        _ value3: Dynamic<Element3>
        ) -> Value3Combiner<Element1, Element2, Element3> {
        
        let context = Value3Combiner(value1, value2, value3)
        sets.append(context)
        return context
    }
    
    public func bind<Element1, Element2, Element3, Element4>(
        _ value1: Dynamic<Element1>,
        _ value2: Dynamic<Element2>,
        _ value3: Dynamic<Element3>,
        _ value4: Dynamic<Element4>
        ) -> Value4Combiner<Element1, Element2, Element3, Element4> {
        
        let context = Value4Combiner(value1, value2, value3, value4)
        sets.append(context)
        return context
    }
    
    public func bind<Element>(_ value: Dynamic<Element?>, fallbackValue: Element) -> BinderContext<Element> {
        let context = BinderContext(value).withConverter({ $0 ?? fallbackValue })
        sets.append(context)
        return context
    }
    
    public func bind<EventType>(_ event: ControlEvent<EventType>) -> ControlEventContext<EventType> {
        let context = ControlEventContext(event, control: nil)
        sets.append(context)
        return context
    }
    
    public func bind<EventType>(_ event: ControlEvent<EventType>, control: UIControl) -> ControlEventContext<EventType> {
        let context = ControlEventContext(event, control: control)
        sets.append(context)
        return context
    }
    
    public func bind<Element: Equatable>(_ event: ControlProperty<Element>) -> ControlPropertyContext<Element> {
        let context = ControlPropertyContext(event)
        sets.append(context)
        return context
    }
    
    @discardableResult
    public func apply() -> Disposable {
        disposable = Disposables.create(sets.map({ $0.apply() }))
        return disposable!
    }
    
    public func dispose() {
        disposable?.dispose()
    }
}

public extension BindingSet {
    
    func bind(_ searchBar: UISearchBar) -> ControlPropertyContext<String> {
        return self.bind(searchBar.rx.text.orEmpty)
    }
    
    func bind(_ textField: UITextField) -> ControlPropertyContext<String> {
        return self.bind(textField.rx.text.orEmpty)
    }
    
    func bind(_ textView: UITextView) -> ControlPropertyContext<String> {
        return self.bind(textView.rx.text.orEmpty)
    }
    
    func bind(_ datePicker: UIDatePicker) -> ControlPropertyContext<Date> {
        return self.bind(datePicker.rx.date)
    }
    
    func bind(_ button: UIButton) -> ControlEventContext<Void> {
        return self.bind(button.rx.tap, control: button)
    }
}

public extension Reactive where Base: UIView {
    
    func tap(numberOfTouches: Int = 1) -> ControlEvent<Void> {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.numberOfTouchesRequired = numberOfTouches
        
        self.base.addGestureRecognizer(tapGesture)
        
        return ControlEvent(events: tapGesture.rx.event.map({ _ in () }))
    }
    
    func longTap(minimumPressDuration: TimeInterval = 0.5) -> ControlEvent<Void> {
        let tapGesture = UILongPressGestureRecognizer()
        tapGesture.minimumPressDuration = minimumPressDuration
        
        self.base.addGestureRecognizer(tapGesture)
        
        return ControlEvent(events: tapGesture.rx.event.map({ _ in () }))
    }
}
