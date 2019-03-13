//
//  SttKeyboardViewController.swift
//  STT
//
//  Created by Piter Standret on 1/12/19.
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
import UIKit
import RxSwift

open class SttKeyboardViewController<T: SttViewControllerInjector>: SttViewController<T>, SttKeyboardNotificationDelegate {
    
    open var isKeyboardShow: Bool { return _isKeyboardShow }
    open var useCancelGesture = true
    open var cancelsTouchesInView = true
    
    public let keyboardNotification = SttKeyboardNotification()
    fileprivate var scrollAmount: CGFloat = 0
    fileprivate var scrollAmountGeneral: CGFloat = 0
    
    fileprivate var _isKeyboardShow = false
    fileprivate var moveViewUp: Bool = false
    
    private var statusAppDisposable = DisposeBag()
    private var cnstrHeight: NSLayoutConstraint!
    
    public var targetKeyboardConstraint: NSLayoutConstraint!
        
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardNotification.callIfKeyboardIsShow = true
        keyboardNotification.delegate = self
        
        if useCancelGesture {
            let cancelGesture = UITapGestureRecognizer(target: self, action: #selector(handleClick(_:)))
            cancelGesture.cancelsTouchesInView = cancelsTouchesInView
            self.view.addGestureRecognizer(cancelGesture)
        }
        
        SttGlobalObserver.observableStatusApplication.subscribe(onNext: { [unowned self] (status) in
            switch status {
            case .didEnterBackgound:
                self.view.endEditing(true)
                self.navigationController?.navigationBar.endEditing(true)
                self.keyboardNotification.removeObserver()
                print("remove")
            case .willEnterForeground:
                self.keyboardNotification.addObserver()
                print("add")
            default: break;
            }
        }).disposed(by: statusAppDisposable)
    }
    
    @objc
    private func handleClick(_ sender: UITapGestureRecognizer?) {
        let senderView = sender?.view?.hitTest(sender!.location(in: view), with: nil)
        if !(senderView?.tag == 900) {
            view.endEditing(true)
        }
    }
    
 
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Int(viewRect.height) <= Int(view.bounds.height - scrollAmount) {
            
            var frame = view.frame
            frame.size.height -= scrollAmount
            if let cnstr = targetKeyboardConstraint {
                cnstr.constant = scrollAmount
                print(cnstr.constant)
            }
            else {
                view.frame = frame
            }
        }
        keyboardNotification.addObserver()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardNotification.removeObserver()
    }
    
    // MARK: -- SttKeyboardNotificationDelegate
    
    public func keyboardWillShow(height: CGFloat) {
        if view != nil {
            scrollAmount = height - scrollAmountGeneral
            scrollAmountGeneral = height
            
            moveViewUp = true
            scrollTheView(move: moveViewUp)
        }
        _isKeyboardShow = true
    }
    public func keyboardWillHide(height: CGFloat) {
        if moveViewUp {
            scrollTheView(move: false)
        }
        _isKeyboardShow = false
    }
    
    private var viewRect = CGRect.zero
    private func scrollTheView(move: Bool) {
        var frame = view.frame
        if move {
            frame.size.height -= scrollAmount
        }
        else {
            frame.size.height += scrollAmountGeneral
            scrollAmountGeneral = 0
            scrollAmount = 0
        }
        viewRect = frame
        if let cnstr = targetKeyboardConstraint {
            cnstr.constant = scrollAmount
            print(cnstr.constant)
        }
        else {
            view.frame = frame
        }
        if keyboardNotification.isAnimation {
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
