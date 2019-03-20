//
//  SttHandlerTextView.swift
//  STT
//
//  Created by Standret on 27.06.18.
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

public enum TypeActionTextView {
    case didBeginEditing, didEndEditing
    case editing
    case shouldChangeText
    case selectionChanged
}

open class SttHandlerTextView: NSObject, UITextViewDelegate {
    
    // private property
    private var handlers = [TypeActionTextView: [SttDelegatedCall<UITextView>]]()

    public var maxCharacter: Int = Int.max
    
    // method for add target
    
    public func addTarget<T: AnyObject>(type: TypeActionTextView, delegate: T, handler: @escaping (T, UITextView) -> Void) {
        
        handlers[type] = handlers[type] ?? [SttDelegatedCall<UITextView>]()
        handlers[type]?.append(SttDelegatedCall<UITextView>(to: delegate, with: handler))
    }
    
    
    // implements protocol
    
    open func textViewDidBeginEditing(_ textView: UITextView) {
        handlers[.didBeginEditing]?.forEach({ $0.callback(textView) })
    }
    
    open func textViewDidEndEditing(_ textView: UITextView) {
        handlers[.didEndEditing]?.forEach({ $0.callback(textView) })
    }
    
    open func textViewDidChange(_ textView: UITextView) {
        handlers[.editing]?.forEach({ $0.callback(textView) })
    }
    
    open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= maxCharacter    // 10 Limit Value
    }
    
    open func textViewDidChangeSelection(_ textView: UITextView) {
        handlers[.selectionChanged]?.forEach({ $0.callback(textView) })
    }
}
