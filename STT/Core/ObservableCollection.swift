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
    
    public typealias CollectionChanges = ([Int], CollectionObserverType)
    
    private var datas = [Element]()
    private var lock = NSRecursiveLock()
    
    private var notifyPublisher = EventPublisher<CollectionChanges>()
    public var collectionChanges: Event<CollectionChanges> { notifyPublisher }
    
    public var count: Int { datas.count }
    public var capacity: Int { datas.capacity }
    public var startIndex: Int { datas.startIndex }
    public var endIndex: Int { datas.endIndex }
    
    public var first: Element? { datas.first }
    public var last: Element? { datas.last }

    open var array: [Element] { datas }
    
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
        datas.append(newElement)
        lock.unlock()
        
        notify(([datas.count - 1], .insert))
    }
    
    open func append(contentsOf sequence: [Element]) {
        guard sequence.count > 0 else { return }
        
        lock.lock()
        let startIndex = datas.count
        datas.append(contentsOf: sequence)
        lock.unlock()
        
        notify((Array(startIndex..<datas.count), .insert))
    }
    
    open func insert(_ newElement: Element, at index: Int) {
        lock.lock()
        datas.insert(newElement, at: index)
        lock.unlock()
        
        notify(([index], .insert))
    }
    
    open func insert(contentsOf: [Element], at index: Int) {
        lock.lock()
        datas.insert(contentsOf: contentsOf, at: index)
        lock.unlock()
        
        notify((Array(index..<(index + contentsOf.count)), .insert))
    }
    
    open func index(where predicate: (Element) throws -> Bool) rethrows -> Int? {
        lock.lock()
        defer { lock.unlock() }
        
        return try datas.firstIndex(where: predicate)
    }
    
    open func remove(at index: Int) {
        lock.lock()
        datas.remove(at: index)
        lock.unlock()
        
        notify(([index], .delete))
    }
    
    open func removeAll() {
        guard datas.count > 0 else { return }
        
        lock.lock()
        datas.removeAll()
        lock.unlock()
        
        notify(([], .reload))
    }
    
    open func removeAll(where closure: (Element) -> Bool) {
        guard datas.count > 0 else { return }
        
        lock.lock()
        self.datas.removeAll(where: closure)
        lock.unlock()
        
        notify(([], .reload))
    }
    
    open subscript(index: Int) -> Element {
        get {
            lock.lock()
            defer { lock.unlock() }
            return datas[index]
        }
        set(newValue) {
            lock.lock()
            datas[index] = newValue
            lock.unlock()
            notify(([index], .update))
        }
    }
    
    ///
    /// Begins a series of modification methods for collection.
    ///
    open func beginUpdates() {
        isPerformingBatchUpdates = true
    }
    
    ///
    /// Ends and commits all modifications for collection and publish reload event
    ///
    open func endUpdates() {
        guard isPerformingBatchUpdates else { fatalError("endUpdates nothing to commit") }
        isPerformingBatchUpdates = false
        commitChanges()
    }
    
    ///
    /// Performs updates block emiting event just after all actions are finished
    ///
    private var isPerformingBatchUpdates = false
    open func performBatchUpdates(_ updates: (ObservableCollection<Element>) -> Void) {
        guard !isPerformingBatchUpdates else { fatalError("performBatchUpdates can be executed synchronisly") }
        isPerformingBatchUpdates = true
        updates(self)
        isPerformingBatchUpdates = false
        commitChanges()
    }
    
    private func commitChanges() {
        // collection was updated send reload data event
        // TODO:(Standret, romanKovalchuk) look at the effort to add support for, insertions, deletions, modifications
        lock.lock()
        defer { lock.unlock() }
        notify(([], .reload))
    }
    
    private func notify(_ changes: CollectionChanges) {
        // if changes were commited inside updates block we do not need to publish separate event
        guard !isPerformingBatchUpdates else { return }
        // publish event to view
        notifyPublisher.invoke(changes)
    }
    
    // MARK: - deprecated
    
    @available(swift, deprecated: 5.0, renamed: "last")
    open func lastOrNil() -> Element? {
        lock.lock()
        defer { lock.unlock() }
        
        return datas.last
    }
    
    @available(swift, deprecated: 5.0, renamed: "first")
    open func firstOrNil() -> Element? {
        lock.lock()
        defer { lock.unlock() }
        
        return datas.first
    }
}

public extension ObservableCollection {
    func replaceData(with data: [Element]) {
        self.performBatchUpdates { (collection) in
            collection.removeAll()
            collection.append(contentsOf: data)
        }
    }
}
