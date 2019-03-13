//
//  ObservableTypeExt.swift
//  STT
//
//  Created by Standret on 5/13/18.
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

public extension PrimitiveSequence {
    public func toEmptyObservable<T>(ofType _: T.Type) -> Observable<T> {
        return self.asObservable().flatMap({ _ in Observable<T>.empty() })
    }
    public func toObservable() -> Observable<Bool> {
        return Observable<Bool>.create({ (observer) -> Disposable in
            self.asObservable().subscribe(onCompleted: {
                observer.onNext(true)
                observer.onCompleted()
            })
        })
    }
    public func inBackground() -> PrimitiveSequence<Trait, Element> {
        return self.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    public func observeInUI() -> PrimitiveSequence<Trait, Element> {
        return self.observeOn(MainScheduler.instance)
    }
}

public extension Observable {
    public func saveInDB(saveCallback: @escaping (_ saveCallback: Element) -> Completable) -> Observable<Element>
    {
        return self.map({ (element) -> Element in
            _ = saveCallback(element).subscribe(onCompleted: {
                SttLog.trace(message: "\(type(of: Element.self)) has been saved succefully in realm", key: "RepositoryExtension")
            }, onError: { (error) in
                SttLog.error(message: "\(type(of: Element.self)) could not save in db", key: "RepositoryExtension")
            })
            return element
        })
    }
    
    public func toBoolObservable() -> Observable<Bool> {
        return self.map({ _ in true })
    }
    
    public func toVoidObservable() -> Observable<Void> {
        return self.map({ _ in () })
    }
    
    public func inBackground() -> Observable<Element> {
        return self.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    public func observeInUI() -> Observable<Element> {
        return self.observeOn(MainScheduler.instance)
    }
}
