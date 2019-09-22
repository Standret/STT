//
//  Event.swift
//  STT
//
//  Created by Peter Standret on 9/15/19.
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

open class EventDisposable {
    
    private let _dispose: () -> ()
    
    public init(_ dispose: @escaping () -> ()) {
        self._dispose = dispose
    }
    
    ///
    /// Destroy subscription and stop receiving events
    ///
    open func dispose() {
        _dispose()
    }
    
    ///
    /// Add current disposable to array of disposables
    ///
    open func add(to disposal: inout [EventDisposable]) {
        disposal.append(self)
    }
    
    deinit {
        dispose()
    }
}

///
/// Simple observable to observe on state changes
///
open class Event<Element> {
    
    public typealias Observer = (Element) -> Void
    
    private var uniqueID = (0...).makeIterator()
    
    fileprivate var lock = NSRecursiveLock()
    fileprivate var observers: [Int: (Observer, DispatchQueue?)] = [:]
    
    fileprivate var hasBuffer: Bool = false
    fileprivate var lastElement: Element?
    
    public init(hasBuffer: Bool = false) {
        self.hasBuffer = hasBuffer
    }
    
    ///
    /// Subsribe on new changes
    /// - Parameter queue: observation queue
    /// - Parameter observer: target changes observer
    ///
    open func subscribe(
        _ queue: DispatchQueue? = nil,
        _ observer: @escaping Observer
        ) -> EventDisposable {
        
        lock.lock()
        defer { lock.unlock() }
        
        let id = uniqueID.next()!
        observers[id] = (observer, queue)
        
        let disposable = EventDisposable { [weak self] in
            self?.observers[id] = nil
        }
        
        if hasBuffer, let element = lastElement {
            if let queue = queue {
                queue.async {
                    observer(element)
                }
            }
            else {
                observer(element)
            }
        }
        
        return disposable
    }
    
    ///
    /// Subsribe on new changes
    /// - Parameter observer: target changes observer
    ///
    open func subscribe(_ observer: @escaping Observer) -> EventDisposable {
        
        lock.lock()
        defer { lock.unlock() }
        
        let id = uniqueID.next()!
        observers[id] = (observer, nil)
        
        let disposable = EventDisposable { [weak self] in
            self?.observers[id] = nil
        }
        
        if hasBuffer, let element = lastElement {
           observer(element)
        }
        
        return disposable
    }
}

///
/// Event publisher
///
open class EventPublisher<Element>: Event<Element> {
    
    ///
    /// Notify all subsribers about value changes
    ///
    open func invoke(_ element: Element) {
        lock.lock()
        defer { lock.unlock() }
        
        lastElement = element
        observers.values.forEach { observer, dispatchQueue in
            if let dispatchQueue = dispatchQueue {
                dispatchQueue.async {
                    observer(element)
                }
            }
            else {
                observer(element)
            }
        }
    }
    
    ///
    /// Clear all subsribtion for the event
    ///
    open func clearAllSubsribtion() {
        lock.lock()
        defer { lock.unlock() }
        
        observers = [Int: (Observer, DispatchQueue?)]()
    }
}
