//
//  ViewController.swift
//  STT
//
//  Created by Peter Standret on 9/13/19.
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

public protocol ViewControllerType {
    
    associatedtype Presenter: PresenterType
    
    var presenter: Presenter! { get }
    
    func style()
    func bind()
}

public extension ViewControllerType {
    
    func style() { }
    func bind() { }
}

open class ViewController<Presenter: PresenterType>: UIViewController, ViewControllerType {
    
    open var presenter: Presenter!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewCreated()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewAppearing()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewAppeared()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.viewDisappearing()
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.viewDisappeared()
    }
    
    open func style() { }
    open func bind() { }
}

open class KeyboardViewController<Presenter: PresenterType>: ViewController<Presenter>, KeyboardNotificationDelegate {
    
    open var useCancelGesture = true
    open var cancelsTouchesInView = true
    
    private var scrollAmount: CGFloat = 0
    private var scrollAmountGeneral: CGFloat = 0
    private var moveViewUp: Bool = false

    public let keyboardNotification = KeyboardNotification()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardNotification.callIfKeyboardIsShow = true
        keyboardNotification.delegate = self
        
        if useCancelGesture {
            let cancelGesture = UITapGestureRecognizer(target: self, action: #selector(handleClick(_:)))
            cancelGesture.cancelsTouchesInView = cancelsTouchesInView
            view.addGestureRecognizer(cancelGesture)
        }
    }
    
    open func shouldCloseKeyboard(sender: UIView?) -> Bool {
        return true
    }
    
    @objc
    private func handleClick(_ sender: UITapGestureRecognizer?) {
        if shouldCloseKeyboard(sender: sender?.view) {
            view.endEditing(true)
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        keyboardNotification.addObserver()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        keyboardNotification.removeObserver()
    }
    
    // MARK: -- SttKeyboardNotificationDelegate
    
    open func keyboardWillShow(height: CGFloat) {
        if view != nil {
            scrollAmount = height - scrollAmountGeneral
            scrollAmountGeneral = height
            
            moveViewUp = true
            scrollTheView(move: moveViewUp)
        }
    }
    
    open func keyboardWillHide(height: CGFloat) {
        if moveViewUp {
            scrollTheView(move: false)
        }
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
        view.frame = frame
        
        if keyboardNotification.isAnimation {
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
