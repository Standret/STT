//
//  KeyboardNotification.swift
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

public protocol KeyboardNotificationDelegate: AnyObject {
    
    var callIfKeyboardIsShow: Bool { get }
    var isAnimatedKeyboard: Bool { get }
    
    func keyboardWillShow(height: CGFloat)
    func keyboardWillHide(height: CGFloat)
}

public final class KeyboardNotification {
    
    public static var shared = KeyboardNotification()
    
    public var isEnabled = true
    public private(set) var isActive: Bool = false
    
    public var bounds: CGRect {
        if let frame: NSValue = notificationObject?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            return frame.cgRectValue
        }
        
        return CGRect()
    }
    
    public private(set) var isKeyboardShow: Bool = false
    public var heightKeyboard: CGFloat { return bounds.height }
    
    private var notificationObject: Notification!
    private var delegates = MulticastDelegate<KeyboardNotificationDelegate>()
    
    private init() {
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
    
    public func removeObserver(delegate: KeyboardNotificationDelegate) {
        delegates -= delegate
    }
    
    public func addObserver(delegate: KeyboardNotificationDelegate) {
        delegates += delegate
    }
    
    @objc private func keyboardWillShow(_ notification: Notification?) {
        
        isKeyboardShow = true
        notificationObject = notification
        
        delegates.invokeDelegates({
            if $0.callIfKeyboardIsShow || !isKeyboardShow {
                $0.keyboardWillShow(height: heightKeyboard)
            }
        })
    }
    
    @objc private func keyboardWillHide(_ notification: Notification?) {
        
        isKeyboardShow = false
        notificationObject = notification
        
        delegates.invokeDelegates({
            if $0.callIfKeyboardIsShow || !isKeyboardShow {
                $0.keyboardWillHide(height: heightKeyboard)
            }
        })
    }
}
