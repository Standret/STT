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

public struct ObservableCollectionChangeTransaction {
    
    public enum Change: Hashable {
        case deleteSections(indexes: [Int])
        case insertSections(indexes: [Int])
        case updateSections(indexes: [Int])
        
        case delete(indexes: [IndexPath])
        case insert(indexes: [IndexPath])
        case update(indexes: [IndexPath])
        case reload
        
        func change(with section: Int) -> Change {
            switch self {
            case .reload: return .reload
            case .delete(let indexes):
                return .delete(indexes: indexes.map { IndexPath(row: $0.row, section: section) })
            case .insert(let indexes):
                return .insert(indexes: indexes.map { IndexPath(row: $0.row, section: section) })
            case .update(let indexes):
                return .update(indexes: indexes.map { IndexPath(row: $0.row, section: section) })
            default:
                fatalError()
            }
        }
    }

    let changes: [Change]
    let completion: (Bool) -> Void
}

public protocol CollectionChangeObservable {
    var collectionChanges: Event<ObservableCollectionChangeTransaction> { get }
}

open class ObservableCollection<Element: AnyObject>: Collection, CollectionChangeObservable {
    
    private var datas = [Element]()
    private var lock = NSRecursiveLock()
    
    private var notifyPublisher = EventPublisher<ObservableCollectionChangeTransaction>()
    public var collectionChanges: Event<ObservableCollectionChangeTransaction> { notifyPublisher }
    
    public var count: Int { datas.count }
    public var capacity: Int { datas.capacity }
    public var startIndex: Int { datas.startIndex }
    public var endIndex: Int { datas.endIndex }
    
    public var first: Element? { datas.first }
    public var last: Element? { datas.last }

    open var array: [Element] { datas }
    
    private var isPerformingBatchUpdates = false
    private var notifyChangesQueue: [ObservableCollectionChangeTransaction.Change] = []
    
    // reflect all changes if collection has as elements other ObservableCollection
    private var subCollectionDisposables: [EventDisposable?] = []
    
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
        subscribeOnElementIfNeeded(newElement) {
            subCollectionDisposables.append($0)
        }
        lock.unlock()

        if isElementObservableCollection() {
            notify(.insertSections(indexes: [datas.count - 1]))
        } else {
            notify(.insert(indexes: [IndexPath(row: datas.count - 1, section: 0)]))
        }
    }
    
    open func append(contentsOf newElements: [Element]) {
        guard !newElements.isEmpty else { return }

        lock.lock()
        let startIndex = datas.count
        datas.append(contentsOf: newElements)
        
        for element in newElements {
            subscribeOnElementIfNeeded(element) {
                subCollectionDisposables.append($0)
            }
        }
        lock.unlock()

        let insertedIndexes = Array(startIndex..<datas.count)
        if isElementObservableCollection() {
            notify(.insertSections(indexes: insertedIndexes))
        } else {
            notify(.insert(indexes: insertedIndexes.map({ IndexPath(row: $0, section: 0) })))
        }
    }
    
    open func insert(_ newElement: Element, at index: Int) {
        lock.lock()
        datas.insert(newElement, at: index)
        subscribeOnElementIfNeeded(newElement) {
            subCollectionDisposables.insert($0, at: index)
        }
        lock.unlock()

        if isElementObservableCollection() {
            notify(.insertSections(indexes: [index]))
        } else {
            notify(.insert(indexes: [IndexPath(row: index, section: 0)]))
        }
    }
    
    open func insert(contentsOf newElements: [Element], at index: Int) {
        guard !newElements.isEmpty else { return }
        
        lock.lock()
        datas.insert(contentsOf: newElements, at: index)
        
        var disposables: [EventDisposable] = []
        for element in newElements {
            subscribeOnElementIfNeeded(element) {
                disposables.append($0)
            }
        }
        subCollectionDisposables.insert(contentsOf: disposables, at: index)
        lock.unlock()
        
        let insertedIndexes = Array(index..<(index + newElements.count))
        if isElementObservableCollection() {
            notify(.insertSections(indexes: insertedIndexes))
        } else {
            notify(.insert(indexes: insertedIndexes.map { IndexPath(row: $0, section: 0) }))
        }
    }
    
    open func index(where predicate: (Element) throws -> Bool) rethrows -> Int? {
        lock.lock()
        defer { lock.unlock() }
        
        return try datas.firstIndex(where: predicate)
    }
    
    open func remove(at index: Int) {
        lock.lock()
        datas.remove(at: index)
        if isElementObservableCollection() {
            subCollectionDisposables.remove(at: index)
        }
        lock.unlock()
        
        if isElementObservableCollection() {
            notify(.deleteSections(indexes: [index]))
        } else {
            notify(.delete(indexes: [IndexPath(row: index, section: 0)]))
        }
    }
    
    open func removeAll() {
        guard !datas.isEmpty else { return }
        
        lock.lock()
        let countBeforeRemoval = datas.count
        datas.removeAll()
        subCollectionDisposables.removeAll()
        lock.unlock()
        
        let indexesToRemove = Array(0..<countBeforeRemoval)
        if isElementObservableCollection() {
            notify(.deleteSections(indexes: indexesToRemove))
        } else {
            notify(.delete(indexes: indexesToRemove.map { IndexPath(row: $0, section: 0) }))
        }
    }
    
    open func removeAll(where closure: (Element) -> Bool) {
        guard datas.count > 0 else { return }
        
        lock.lock()
        let indexesToRemove = datas.enumerated().compactMap({
            if closure($0.element) {
                return $0.offset
            }
            return nil
        })
        datas.removeAll(where: closure)
        // only update subCollectionDisposables if Element is also observable collection and a subscribtion exists
        if isElementObservableCollection() {
            indexesToRemove.forEach({ subCollectionDisposables[$0] = nil })
            subCollectionDisposables.removeAll(where: { $0 == nil })
        }
        lock.unlock()
        
        if isElementObservableCollection() {
            notify(.deleteSections(indexes: indexesToRemove))
        } else {
            notify(.delete(indexes: indexesToRemove.map({ IndexPath(row: $0, section: 0) })))
        }
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
            subscribeOnElementIfNeeded(newValue) {
                subCollectionDisposables[index] = $0
            }
            lock.unlock()
            
            if isElementObservableCollection() {
                notify(.updateSections(indexes: [index]))
            } else {
                notify(.update(indexes: [IndexPath(row: index, section: 0)]))
            }
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
    open func endUpdates(reload: Bool = true, completion: @escaping (Bool) -> Void = { _ in }) {
        guard isPerformingBatchUpdates else { fatalError("endUpdates nothing to commit") }
        isPerformingBatchUpdates = false
        commitChanges(reload: reload, completion: completion)
    }
    
    ///
    /// Performs updates block emiting event just after all actions are finished
    ///
    open func performBatchUpdates(reload: Bool = true, _ updates: (ObservableCollection<Element>) -> Void, completion: @escaping (Bool) -> Void = { _ in }) {
        guard !isPerformingBatchUpdates else { fatalError("performBatchUpdates can be executed synchronisly") }
        isPerformingBatchUpdates = true
        updates(self)
        isPerformingBatchUpdates = false
        commitChanges(reload: reload, completion: completion)
    }
    
    private func commitChanges(reload: Bool = true, completion: @escaping (Bool) -> Void) {
        // collection was updated send reload data event
        // TODO:(Standret, romanKovalchuk) look at the effort to add support for, insertions, deletions, modifications
        lock.lock()
        defer { lock.unlock() }
        
        if reload {
            notify(.reload)
        } else {
            notify(notifyChangesQueue, completion: completion)
        }
        
        notifyChangesQueue = []
    }
    
    private func notify(_ change: ObservableCollectionChangeTransaction.Change, completion: @escaping (Bool) -> Void = { _ in }) {
        self.notify([change], completion: completion)
    }
    
    private func notify(_ changes: [ObservableCollectionChangeTransaction.Change], completion: @escaping (Bool) -> Void = { _ in }) {
        // if changes were commited inside updates block we do not need to publish separate event
        guard !isPerformingBatchUpdates else {
            notifyChangesQueue.append(contentsOf: changes)
            return
        }
        // publish event to view
        notifyPublisher.invoke(ObservableCollectionChangeTransaction(changes: changes, completion: completion))
    }
    
    private func subscribeOnElementIfNeeded(_ element: Element, disposeSave: (EventDisposable) -> Void) {
        guard let collection = element as? CollectionChangeObservable else { return }
        disposeSave(collection.collectionChanges.subscribe { [unowned self] transaction in
            self.reflect(transaction: transaction, for: element)
        })
    }
    
    private func reflect(transaction: ObservableCollectionChangeTransaction, for element: Element) {
        guard let index = datas.firstIndex(where: { $0 === element }) else { return }
        notify(transaction.changes.map({ $0.change(with: index) }), completion: transaction.completion)
    }
    
    private func isElementObservableCollection() -> Bool {
        return Element.self is CollectionChangeObservable.Type
    }
}

public extension ObservableCollection {
    
    func replaceData(with data: [Element], completion: @escaping (Bool) -> Void = { _ in }) {
        self.performBatchUpdates(reload: false, { (collection) in
            collection.removeAll()
            collection.append(contentsOf: data)
        }, completion: completion)
    }
}
