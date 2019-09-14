//
//  KeyboardViewController.swift
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
import UIKit

open class KeyboardViewController<Presenter: PresenterType>: ViewController<Presenter> {
    
    open var isKeyboardAnimated = true
    open var useCancelGesture = true
    open var cancelsTouchesInView = true
    
    private var scrollAmount: CGFloat = 0
    private var scrollAmountGeneral: CGFloat = 0
    private var viewRect = CGRect.zero
    
    private var moveViewUp: Bool = false
    private var isMovingUp: Bool = false
    private var isDisappearing: Bool = false
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    private var originalViewSize = CGSize.zero
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard originalViewSize.height < view.bounds.size.height else { return }
        
        originalViewSize = view.bounds.size
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if viewRect != CGRect.zero && originalViewSize == view.frame.size {
            view.frame = viewRect
        }
        
        guard !isDisappearing && originalViewSize == view.frame.size  else { return }
        
        if KeyboardNotification.shared.isKeyboardShow {
            self.keyboardWillShow(height: KeyboardNotification.shared.heightKeyboard)
        }
        else {
            self.keyboardWillHide(height: KeyboardNotification.shared.heightKeyboard)
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        isDisappearing = false
        super.viewDidAppear(animated)
        
        KeyboardNotification.shared.addObserver(delegate: self)
        GlobalObserver.shared.addObserver(delegate: self)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        isDisappearing = true
        super.viewWillDisappear(animated)
        
        KeyboardNotification.shared.removeObserver(delegate: self)
        GlobalObserver.shared.removeObserver(delegate: self)
    }
}

// MARK: - implementation of KeyboardNotificationDelegate

extension KeyboardViewController: KeyboardNotificationDelegate {
    
    open var callIfKeyboardIsShow: Bool { return true }
    open var isAnimatedKeyboard: Bool { return isKeyboardAnimated }
    
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
    
    private func scrollTheView(move: Bool) {
        
        guard !isMovingUp else { return }
        isMovingUp = true
        
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
        
        if isAnimatedKeyboard {
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
        
        isMovingUp = false
    }
}

// MARK: - implementation of GlobalObserverDelegate

extension KeyboardViewController: GlobalObserverDelegate {
    
    public func applicationStatusChanged(with status: ApplicationStatus) {
        switch status {
        case .didEnterBackgound:
            KeyboardNotification.shared.removeObserver(delegate: self)
        case .willEnterForeground:
            KeyboardNotification.shared.addObserver(delegate: self)
        default: break
        }
    }
}
