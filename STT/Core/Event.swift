//
//  Event.swift
//  STT
//
//  Created by Peter Standret on 9/15/19.
//  Copyright © 2019 standret. All rights reserved.
//

import Foundation

open class Disposable {
    
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
    
    ///
    /// Subsribe on new changes
    /// - Parameter queue: observation queue
    /// - Parameter observer: target changes observer
    ///
    open func subsribe(
        _ queue: DispatchQueue? = nil,
        _ observer: @escaping Observer
        ) -> Disposable {
        
        lock.lock()
        defer { lock.unlock() }
        
        let id = uniqueID.next()!
        observers[id] = (observer, queue)
        
        let disposable = Disposable { [weak self] in
            self?.observers[id] = nil
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
