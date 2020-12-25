//
//  CommandType.swift
//  STT
//
//  Created by Peter Standret on 9/21/19.
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

public enum CommandState {
    case start
    case end
}

public protocol CommandType: AnyObject {
    
    var canNext: Event<Bool> { get }
    
    var isExecuting: Bool { get }
    
    var allowConcurentExecution: Bool { get set }
    var singleCallEndCallback: Bool { get set }
    
    func execute(parameter: Any?)
    func canExecute(parameter: Any?) -> Bool
    
    func raiseCanExecute(parameter: Any?)
    
    func observe(start: (() -> Void)?, end: (() -> Void)?) -> EventDisposable
    func observe(handler: @escaping (Bool) -> Void) -> EventDisposable
    
    func changeState(state: CommandState)
}

public extension CommandType {
    
    func execute(parameter: Any? = nil) {
        return self.execute(parameter: parameter)
    }
    
    func canExecute(parameter: Any? = nil) -> Bool {
        return self.canExecute(parameter: parameter)
    }
    
    func raiseCanExecute(parameter: Any? = nil) {
        return self.raiseCanExecute(parameter: parameter)
    }
    
    func observe(start: (() -> Void)? = nil, end: (() -> Void)? = nil) -> EventDisposable {
        return self.observe(start: start, end: end)
    }
    
    func observe(handler: @escaping (Bool) -> Void) -> EventDisposable {
        return self.observe(handler: handler)
    }
}


open class Command: CommandType {
    
    private var canNextSubject = EventPublisher<Bool>(hasBuffer: false)
    internal var eventSubject = EventPublisher<Bool>(hasBuffer: false)
    
    private var executeHandler: (() -> Void)
    private var canExecuteHandler: (() -> Bool)?
    
    public var canNext: Event<Bool> { return canNextSubject }
    
    private(set) public var isExecuting = false
    
    public var allowConcurentExecution = false
    public var singleCallEndCallback = true
    
    public init<T: AnyObject>(
        delegate: T,
        handler: @escaping (T) -> Void,
        handlerCanExecute: ((T) -> Bool)? = nil
        ) {
        
        executeHandler = { [weak delegate] in
            if let delegate = delegate {
                handler(delegate)
            }
        }
        
        canExecuteHandler = { [weak delegate, weak self] in
            guard let `self` = self,
                let delegate = delegate else { return false }
            
            if let handlerCanExecute = handlerCanExecute {
                return handlerCanExecute(delegate) && (self.allowConcurentExecution || !self.isExecuting)
            }
            
            return self.allowConcurentExecution || !self.isExecuting
        }
        
        isExecuting = false
    }
    
    deinit {
        canNextSubject.clearAllSubsribtion()
        eventSubject.clearAllSubsribtion()
    }
    
    public func execute(parameter: Any?) {
        self.execute()
    }
    public func canExecute(parameter: Any?) -> Bool {
        return self.canExecute()
    }
    
    public func raiseCanExecute(parameter: Any?) {
        canNextSubject.invoke(canExecute())
    }
    
    public func execute() {
        if canExecute() {
            executeHandler()
        }
        else {
            SttLog.shared.verbose("Command could not be execute. Can execute return: \(canExecute())")
        }
    }
    public func canExecute() -> Bool {
        if let handler = canExecuteHandler {
            return handler()
        }
        return true
    }
    
    public func observe(start: (() -> Void)?, end: (() -> Void)?) -> EventDisposable {
        return eventSubject.subscribe({ isStart in isStart ? start?() : end?() })
    }
    
    public func observe(handler: @escaping (Bool) -> Void) -> EventDisposable {
        return eventSubject.subscribe(handler)
    }
    
    public func changeState(state: CommandState) {
        eventSubject.invoke(state == .start)
        isExecuting = state == .start
    }
}

open class CommandWithParameter<TParameter>: CommandType {
    
    private var canNextSubject = EventPublisher<Bool>(hasBuffer: false)
    private var eventSubject = EventPublisher<Bool>(hasBuffer: false)
    
    private var executeHandler: ((TParameter) -> Void)
    internal var canExecuteHandler: ((TParameter) -> Bool)?
    
    public var canNext: Event<Bool> { return canNextSubject }
    
    private(set) public var isExecuting = false

    public var allowConcurentExecution: Bool = false
    public var singleCallEndCallback = true
    
    public init<T: AnyObject> (
        delegate: T,
        handler: @escaping (T, TParameter) -> Void,
        handlerCanExecute: ((T, TParameter) -> Bool)? = nil
        ) {
        
        executeHandler = { [weak delegate] parametr in
            if let delegate = delegate {
                handler(delegate, parametr)
            }
        }
        canExecuteHandler = { [weak delegate, weak self] parametr in
            guard let `self` = self,
                let delegate = delegate else { return false }
            
            if let handlerCanExecute = handlerCanExecute {
                return handlerCanExecute(delegate, parametr) && (self.allowConcurentExecution || !self.isExecuting)
            }
            
            return self.allowConcurentExecution || !self.isExecuting

        }
        
        isExecuting = false
    }
    
    deinit {
        canNextSubject.clearAllSubsribtion()
        eventSubject.clearAllSubsribtion()
    }
    
    public func execute(parameter: Any?) {
        self.execute(parametr: parameter as! TParameter)
    }
    public func canExecute(parameter: Any?) -> Bool {
        return self.canExecute(parametr: parameter as! TParameter)
    }
    
    public func raiseCanExecute(parameter: Any?) {
        canNextSubject.invoke(canExecute(parameter: parameter))
    }
    
    public func execute(parametr: TParameter) {
        if canExecute(parametr: parametr) {
            executeHandler(parametr)
        }
        else {
            SttLog.shared.verbose("Command could not be execute. Can execute return with parametr \(parametr) return: \(canExecute(parametr: parametr))")
        }
    }
    public func canExecute(parametr: TParameter) -> Bool {
        if let handler = canExecuteHandler {
            return handler(parametr)
        }
        return true
    }
    
    
    public func observe(start: (() -> Void)?, end: (() -> Void)?) -> EventDisposable {
        return eventSubject.subscribe({ isStart in isStart ? start?() : end?() })
    }
    
    public func observe(handler: @escaping (Bool) -> Void) -> EventDisposable {
        return eventSubject.subscribe(handler)
    }
    
    public func changeState(state: CommandState) {
        eventSubject.invoke(state == .start)
        isExecuting = state == .start
    }
}
