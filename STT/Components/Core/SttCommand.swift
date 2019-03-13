//
//  SttCommand.swift
//  STT
//
//  Created by Peter Standret on 3/13/19.
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

public class SttCommand: SttCommandType {
    
    private var canNextSubject = PublishSubject<Bool>()
    private var eventSubject = PublishSubject<Bool>()
    private var executeHandler: (() -> Void)
    private var canExecuteHandler: (() -> Bool)?
    
    public var observableCanNext: Observable<Bool> { return canNextSubject }
    
    private var isCalling = false
    
    public var concurentExecute: Bool = false
    
    public var singleCallEndCallback = true
    
    public init<T: SttPresenterType> (delegate: T, handler: @escaping (T) -> Void, handlerCanExecute: ((T) -> Bool)? = nil) {
        executeHandler = { [weak delegate] in
            if let _delegate = delegate {
                handler(_delegate)
            }
        }
        canExecuteHandler = { [weak delegate, weak self] in
            if delegate != nil && handlerCanExecute != nil {
                if let _self = self {
                    return handlerCanExecute!(delegate!) && (_self.concurentExecute || !_self.isCalling)
                }
            }
            else if let _self = self {
                return (_self.concurentExecute || !_self.isCalling)
            }
            return true
        }
        isCalling = false
    }
    
    deinit {
        canNextSubject.dispose()
        eventSubject.dispose()
    }
    
    public func execute(parametr: Any?) {
        self.execute()
    }
    public func canExecute(parametr: Any?) -> Bool {
        return self.canExecute()
    }
    
    public func raiseCanExecute(parametr: Any?) {
        canNextSubject.onNext(canExecute())
    }
    
    public func execute() {
        if canExecute() {
            executeHandler()
        }
        else {
            SttLog.trace(message: "Command could not be execute. Can execute return: \(canExecute())", key: "SttComand")
        }
    }
    public func canExecute() -> Bool {
        if let handler = canExecuteHandler {
            return handler()
        }
        return true
    }
    
    // TODO: Probably needed add call end on disposed
    public func useWork(start: (() -> Void)?, end: (() -> Void)?) -> Disposable {
        
        return eventSubject.subscribe(onNext: { res in
            if res {
                start?()
            }
            else {
                end?()
            }
        })
    }
    public func useWork(handler: @escaping (Bool) -> Void) -> Disposable {
        return eventSubject.subscribe(onNext: handler)
    }
    
    public func useWork<T>(observable: Observable<T>) -> Observable<T> {
        return observable.do(onNext: { (element) in
            if self.singleCallEndCallback && self.isCalling {
                self.eventSubject.onNext(false)
                self.isCalling = false
            }
        }, onError: { (error) in
            if self.isCalling {
                self.eventSubject.onNext(false)
                self.isCalling = false
            }
        }, onCompleted: {
            if self.isCalling {
                self.eventSubject.onNext(false)
                self.isCalling = false
            }
        }, onSubscribed: {
            self.eventSubject.onNext(true)
            self.isCalling = true
        }, onDispose: {
            if self.isCalling {
                self.eventSubject.onNext(false)
                self.isCalling = false
            }
        })
    }
}

public class SttComandWithParametr<TParametr>: SttCommandType {
    
    private var canNextSubject = PublishSubject<Bool>()
    private var eventSubject = PublishSubject<Bool>()
    private var executeHandler: ((TParametr) -> Void)
    private var canExecuteHandler: ((TParametr) -> Bool)?
    
    private var isCalling = false
    
    public var observableCanNext: Observable<Bool> { return canNextSubject }
    
    public var concurentExecute: Bool = false
    
    public var singleCallEndCallback = true
    
    public init<T: SttPresenterType> (delegate: T, handler: @escaping (T, TParametr) -> Void, handlerCanExecute: ((T, TParametr) -> Bool)? = nil) {
        executeHandler = { [weak delegate] parametr in
            if let _delegate = delegate {
                handler(_delegate, parametr)
            }
        }
        canExecuteHandler = { [weak delegate, weak self] parametr in
            if delegate != nil && handlerCanExecute != nil {
                if let _self = self {
                    return handlerCanExecute!(delegate!, parametr) && (_self.concurentExecute || !_self.isCalling)
                }
            }
            else if let _self = self {
                return (_self.concurentExecute || !_self.isCalling)
            }
            return true
        }
        isCalling = false
    }
    
    deinit {
        canNextSubject.dispose()
        eventSubject.dispose()
    }
    
    public func execute(parametr: Any?) {
        self.execute(parametr: parametr as! TParametr)
    }
    public func canExecute(parametr: Any?) -> Bool {
        return self.canExecute(parametr: parametr as! TParametr)
    }
    
    public func raiseCanExecute(parametr: Any?) {
        canNextSubject.onNext(canExecute(parametr: parametr))
    }
    
    public func execute(parametr: TParametr) {
        if canExecute(parametr: parametr) {
            executeHandler(parametr)
        }
        else {
            SttLog.trace(message: "Command could not be execute. Can execute return with parametr \(parametr) return: \(canExecute(parametr: parametr))", key: "SttComand")
        }
    }
    public func canExecute(parametr: TParametr) -> Bool {
        if let handler = canExecuteHandler {
            return handler(parametr)
        }
        return true
    }
    
    
    // TODO: Probably needed add call end on disposed
    public func useWork(start: (() -> Void)?, end: (() -> Void)?) -> Disposable {
        
        return eventSubject.subscribe(onNext: { res in
            if res {
                start?()
            }
            else {
                end?()
            }
        })
    }
    
    public func useWork(handler: @escaping (Bool) -> Void) -> Disposable {
        return eventSubject.subscribe(onNext: handler)
    }
    public func useWork<T>(observable: Observable<T>) -> Observable<T> {
        return observable.do(onNext: { (element) in
            if self.singleCallEndCallback && self.isCalling {
                self.eventSubject.onNext(false)
                self.isCalling = false
            }
        }, onError: { (error) in
            if self.isCalling {
                self.eventSubject.onNext(false)
                self.isCalling = false
            }
        }, onCompleted: {
            if self.isCalling {
                self.eventSubject.onNext(false)
                self.isCalling = false
            }
        }, onSubscribed: {
            if !self.isCalling {
                self.eventSubject.onNext(true)
                self.isCalling = true
            }
        }, onDispose: {
            if self.isCalling {
                self.eventSubject.onNext(false)
                self.isCalling = false
            }
        })
    }
}
