//
//  SttTextField.swift
//  STT
//
//  Created by Admin on 5/17/18.
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
import UIKit

@IBDesignable
open class SttTextField: UITextField {
    
    private let textChangedSubject = PublishSubject<String?>()
    public var textChanged: Observable<String?> {
        return textChangedSubject
    }
    
    override open var text: String? {
        didSet {
            textChangedSubject.onNext(text)
        }
    }
    
    @objc
    open dynamic var insets: UIEdgeInsets = UIEdgeInsets.zero
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return insertRect(rect: bounds, insets: insets)
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return insertRect(rect: bounds, insets: insets)
    }
    
    override open func caretRect(for position: UITextPosition) -> CGRect {
        
        var rect = super.caretRect(for: position)
        rect.size.width = 2
        return rect
    }
    
    private func insertRect(rect: CGRect, insets: UIEdgeInsets) -> CGRect {
        return CGRect(x: Double(rect.minX + insets.left), y: Double(rect.minY + insets.top),
                      width: Double(rect.width - insets.left - insets.right), height: Double(rect.height - insets.top - insets.bottom))
    }
}
