//
//  KeyboardNotification.swift
//  STT
//
//  Created by Standret on 22.06.18.
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

public protocol KeyboardNotificationDelegate: class {
    func keyboardWillShow(height: CGFloat)
    func keyboardWillHide(height: CGFloat)
}

public class KeyboardNotification {
    
    public var isAnimation: Bool = true
    public var callIfKeyboardIsShow: Bool = false
    
    public weak var delegate: KeyboardNotificationDelegate!
    
    private var isActive: Bool = false
    
    public var bounds: CGRect {
        if let frame: NSValue = notificationObject?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            return frame.cgRectValue
        }
        return CGRect()
    }
    
    public var heightKeyboard: CGFloat { return bounds.height }
    
    private var isKeyboardShow: Bool = true
    private var notificationObject: Notification!
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }
    
    public func removeObserver() {
        isActive = false
    }
    
    public func addObserver() {
        isActive = true
    }
    
    
    @objc private func keyboardWillShow(_ notification: Notification?) {
        notificationObject = notification
        if (callIfKeyboardIsShow || !isKeyboardShow) && isActive {
            delegate?.keyboardWillShow(height: heightKeyboard)
        }
        isKeyboardShow = true
    }
    @objc private func keyboardWillHide(_ notification: Notification?) {
        notificationObject = notification
        if isActive {
            delegate?.keyboardWillHide(height: heightKeyboard)
        }
        isKeyboardShow = false
    }
}
