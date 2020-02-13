//
//  ControlEventContext.swift
//  STT
//
//  Created by Peter Standret on 9/22/19.
//  Copyright © 2019 standret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class ControlEventContext<EventType>: BindingContextType {
    
    private let event: ControlEvent<EventType>
    private var lazyApplier: Applier!
    private let control: UIControl?
    
    init(_ event: ControlEvent<EventType>, control: UIControl?) {
        self.event = event
        self.control = control
    }
    
    /**
     Add to context Command handler
     
     ### Usage Example: ###
     ````
     set.bind(someButton).to(command, parameter: Any)
     
     ````
        command.raiseCanExecute() used to get correct button state when binding command
     */
    @discardableResult
    public func to<T: CommandType>(_ command: T) -> ControlEventContext<EventType> {
        
        lazyApplier = { [unowned self] in
            
            command.raiseCanExecute()
            
            let canNextDisp = command.canNext.subscribe({ [weak self] isEnabled in self?.control?.isEnabled = isEnabled })
            let subscriber = self.event.subscribe(onNext: { _ in command.execute() })
            return Disposables.create {
                canNextDisp.dispose()
                subscriber.dispose()
            }
        }
        
        return self
    }
    
    /**
     Add to context Command handler
     
     ### Usage Example: ###
     ````
     set.bind(String.self).forProperty { $0.viewElement.property = $1 }
     .to(dynamicProperty)
     
     ````
        command.raiseCanExecute() used to get correct button state when binding command
     */
    @discardableResult
    public func to<T: CommandType>(_ command: T, parameter: Any) -> ControlEventContext<EventType> {
        
        lazyApplier = { [unowned self] in
            
            command.raiseCanExecute(parameter: parameter)
            
            let canNextDisp = command.canNext.subscribe({ [weak self] isEnabled in self?.control?.isEnabled = isEnabled })
            let subscriber = self.event.subscribe(onNext: { _ in command.execute(parameter: parameter) })
            
            return Disposables.create {
                canNextDisp.dispose()
                subscriber.dispose()
            }
        }
        
        return self
    }
    
    @discardableResult
    public func apply() -> Disposable {
        return lazyApplier()
    }
}
