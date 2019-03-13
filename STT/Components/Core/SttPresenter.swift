//
//  SttPresenter.swift
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

open class SttPresenter<TDelegate> : SttViewControllerInjector {
    
    private weak var _delegate: SttViewable!
    private var _notificationError: SttNotificationErrorServiceType?
    private var messageDisposable: Disposable?
    
    public var disposableBag = DisposeBag()
    public var listenerDisposableBag = DisposeBag()
    
    open var delegate: TDelegate? { return _delegate as? TDelegate }
    
    public init (notificationError: SttNotificationErrorServiceType?) {
        _notificationError = notificationError
    }
    
    public func injectView(delegate: SttViewable) {
        self._delegate = delegate
        
        viewDidInjected()
    }
    
    open func viewAppearing() { }
    open func viewAppeared() {
        messageDisposable = _notificationError?.errorObservable
            .observeInUI()
            .subscribe(onNext: { [unowned self] (err) in
                if (self._delegate is SttViewableListener) {
                    (self._delegate as! SttViewableListener).sendError(error: err)
                }
            })
    }
    
    open func viewDissapearing() { }
    open func viewDissapeared() {
        messageDisposable?.dispose()
    }
    
    open func viewDidInjected() { }
    
    open func prepare(parametr: Any?) { }
    
    open func disposeAllSequence() {
        disposableBag = DisposeBag()
    }
}

open class SttPresenterWithParametr<TDelegate, TParametr>: SttPresenter<TDelegate> {
    
    override open func prepare(parametr: Any?) {
        if let param = parametr {
            prepare(parametr: param as! TParametr)
        }
    }
    
    open func prepare(parametr: TParametr)  { }
}
