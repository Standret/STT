//
//  SttObservableCollection.swift
//  STT
//
//  Created by Piter Standret on 6/16/18.
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

public enum NotifyCollectionType {
    case delete, insert, update, reload
}

open class SttObservableCollection<T>: Collection {
    
    private var datas = [T]()
    private var notifyPublisher = PublishSubject<([Int], NotifyCollectionType)>()
    
    public var observableObject: Observable<([Int], NotifyCollectionType)> { return notifyPublisher }
    public var count: Int { return datas.count }
    public var capacity: Int { return datas.capacity }
    public var startIndex: Int { return datas.startIndex }
    public var endIndex: Int { return datas.endIndex }
    
    open func index(after i: Int) -> Int {
        return datas.index(after: i)
    }
    
    open func append(_ newElement: T) {
        datas.append(newElement)
        notifyPublisher.onNext(([datas.count - 1], .insert))
    }
    open func append(contentsOf sequence: [T]) {
        if sequence.count > 0 {
            let startIndex = datas.count
            datas.append(contentsOf: sequence)
            notifyPublisher.onNext((Array(startIndex...(datas.count - 1)), .insert))
        }
    }
    open func remove(at index: Int) {
        datas.remove(at: index)
        notifyPublisher.onNext(([index], .delete))
    }
    open func insert(_ newElement: T, at index: Int) {
        datas.insert(newElement, at: index)
        notifyPublisher.onNext(([index], .insert))
    }
    open func index(where predicate: (T) throws -> Bool) rethrows -> Int? {
        return try datas.index(where: predicate)
    }
    open func removeAll() {
        if datas.count > 0 {
            datas.removeAll()
            notifyPublisher.onNext(([], .reload))
        }
    }
    open func lastOrNil() -> T? {
        return datas.last
    }
    open func firstOrNil() -> T? {
        return datas.first
    }
    
    open subscript(index: Int) -> T {
        get { return datas[index] }
        set(newValue) {
            datas[index] = newValue
            notifyPublisher.onNext(([index], .update))
        }
    }
}
