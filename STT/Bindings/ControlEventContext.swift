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
    
    init(_ event: ControlEvent<EventType>) {
        self.event = event
    }
    
    /**
     Add to context Command handler
     
     ### Usage Example: ###
     ````
     set.bind(String.self).forProperty { $0.viewElement.property = $1 }
     .to(dynamicProperty)
     
     ````
     */
    @discardableResult
    public func to<T: CommandType>(_ command: T) -> ControlEventContext<EventType> {
        
        lazyApplier = { [unowned self] in
            self.event.subscribe(onNext: { _ in command.execute() })
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
     */
    @discardableResult
    public func to<T: CommandType>(_ command: T, parameter: Any) -> ControlEventContext<EventType> {
        
        lazyApplier = { [unowned self] in
            self.event.subscribe(onNext: { _ in command.execute(parameter: parameter) })
        }
        
        return self
    }
    
    @discardableResult
    public func apply() -> Disposable {
        return lazyApplier()
    }
}
