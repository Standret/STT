//
//  Dynamic.swift
//  STT
//
//  Created by Peter Standret on 9/22/19.
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

/**
 A dynamic property which inform subscribers about value changing
 */
public class Dynamic<Element> {
    
    public typealias Listener = (Element) -> Void
    
    private var disposeBag = DisposeBag()
    private var publisher: PublishSubject<Element>
    
    private var lock = NSRecursiveLock()
    
    private var storeValue: Element
    public var value: Element {
        get {
            lock.lock()
            defer { lock.unlock() }
            
            return storeValue
        }
        set {
            lock.lock()
            storeValue = newValue
            lock.unlock()
            
            publisher.onNext(newValue)
        }
    }
    
    public init(_ value: Element) {
        storeValue = value
        publisher = PublishSubject()
    }
    
    deinit {
        publisher.onCompleted()
        publisher.dispose()
    }
    
    ///
    /// Subscribe on changes and read current value
    ///
    public func bind(_ listener: @escaping Listener) -> Disposable {
        let disposable = publisher.asObservable()
            .subscribe(onNext: listener)
        
        listener(value)
        
        disposeBag.insert(disposable)
        
        return disposable
    }
    
    ///
    /// Subscribe only on changes
    ///
    public func addListener(_ listener: @escaping Listener) -> Disposable {
        let disposable = publisher.asObservable()
            .subscribe(onNext: listener)
        
        disposeBag.insert(disposable)
        
        return disposable
    }
    
    public func dispose() {
        disposeBag = DisposeBag()
    }
}
