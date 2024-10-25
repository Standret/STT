//
//  Concurency.swift
//  Pods
//
//  Created by Petro Standret on 25.10.2024.
//

import Foundation

public final class ReadWriteLock {
    
    public init() {}
    
    deinit {
           pthread_rwlock_destroy(&rwlock)
       }
    
    private var rwlock: pthread_rwlock_t = {
        var rwlock = pthread_rwlock_t()
        pthread_rwlock_init(&rwlock, nil)
        return rwlock
    }()
    
    public func writeLock() {
        pthread_rwlock_wrlock(&rwlock)
    }
    
    public func readLock() {
        pthread_rwlock_rdlock(&rwlock)
    }
    
    public func unlock() {
        pthread_rwlock_unlock(&rwlock)
    }
}

public class ThreadSafe<A> {
    
    private var tsValue: A
    private let lock = ReadWriteLock()
    
    public init(_ value: A) {
        self.tsValue = value
    }
    
    public var value: A {
        lock.readLock()
        defer {
            lock.unlock()
        }
        return self.tsValue
    }
    public func write(_ closure: (inout A) -> Void) {
        lock.writeLock()
        closure(&self.tsValue)
        lock.unlock()
    }
}
