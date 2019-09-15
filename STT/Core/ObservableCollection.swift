//
//  ObservableCollection.swift
//  STT
//
//  Created by Peter Standret on 9/14/19.
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

public enum CollectionObserverType {
    case delete
    case insert
    case update
    case reload
}

open class ObservableCollection<Element>: Collection {

    private var datas = [Element]()
    
    private var lock = NSRecursiveLock()
    
    private var notifyPublisher = EventPublisher<([Int], CollectionObserverType)>()
    public var collectionChanges: Event<([Int], CollectionObserverType)> { return notifyPublisher }
    
    public var count: Int { return datas.count }
    public var capacity: Int { return datas.capacity }
    public var startIndex: Int { return datas.startIndex }
    public var endIndex: Int { return datas.endIndex }

    open var array: [Element] { return datas }

    public init() { }
    public init(_ data: [Element]) {
        datas = data
    }

    deinit {
        datas.removeAll()
        notifyPublisher.clearAllSubsribtion()
    }

    open func index(after i: Int) -> Int {
        lock.lock()
        defer { lock.unlock() }
        
        return datas.index(after: i)
    }

    open func append(_ newElement: Element) {
        lock.lock()
        defer { lock.unlock() }
        
        datas.append(newElement)
        notifyPublisher.invoke(([datas.count - 1], .insert))
    }
    open func append(contentsOf sequence: [Element]) {
        lock.lock()
        defer { lock.unlock() }
        
        if sequence.count > 0 {
            let startIndex = datas.count
            datas.append(contentsOf: sequence)
            notifyPublisher.invoke((Array(startIndex..<datas.count), .insert))
        }
    }

    open func insert(_ newElement: Element, at index: Int) {
        lock.lock()
        defer { lock.unlock() }
        
        datas.insert(newElement, at: index)
        notifyPublisher.invoke(([index], .insert))
    }
    open func insert(contentsOf: [Element], at index: Int) {
        lock.lock()
        defer { lock.unlock() }
        
        datas.insert(contentsOf: contentsOf, at: index)
        notifyPublisher.invoke((Array(index..<(index + contentsOf.count)), .insert))
    }

    open func index(where predicate: (Element) throws -> Bool) rethrows -> Int? {
        lock.lock()
        defer { lock.unlock() }
        
        return try datas.firstIndex(where: predicate)
    }

    open func remove(at index: Int) {
        lock.lock()
        defer { lock.unlock() }
        
        datas.remove(at: index)
        notifyPublisher.invoke(([index], .delete))
    }
    open func removeAll() {
        lock.lock()
        defer { lock.unlock() }
        guard datas.count > 0 else { return }
        
        datas.removeAll()
        notifyPublisher.invoke(([], .reload))
    }
    open func removeAll(where closure: (Element) -> Bool) {
        lock.lock()
        defer { lock.unlock() }
        guard datas.count > 0 else { return }

        self.datas.removeAll(where: closure)
        notifyPublisher.invoke(([], .reload))
    }
    
    open func lastOrNil() -> Element? {
        lock.lock()
        defer { lock.unlock() }
        
        return datas.last
    }
    open func firstOrNil() -> Element? {
        lock.lock()
        defer { lock.unlock() }
        
        return datas.first
    }

    open subscript(index: Int) -> Element {
        get {
            lock.lock()
            defer { lock.unlock() }
            
            return datas[index]
        }
        set(newValue) {
            lock.lock()
            defer { lock.unlock() }
            
            datas[index] = newValue
            notifyPublisher.invoke(([index], .update))
        }
    }
}
