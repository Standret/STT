//
//  SttTextView.swift
//  STT
//
//  Created by Andriy Popel on 3/20/19.
//  Copyright © 2019 Adrii Popel <andriypopel@gmail.com>
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

internal class SttTextViewPlaceholder: SttHandlerTextView {
    
    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLenght = textView.text.count + text.count - range.length
        return newLenght <= super.maxCharacter
    }
}

open class SttTextView: UITextView {
    
    private(set) public var sttDelegate: SttHandlerTextView!
    
    private var placeHolder: String?
    var isInitialized: Bool?
    var enabledPlaceholder = true
    
    @objc
    public dynamic var placeHolderColor: UIColor = .lightGray
    public var maxLength: Int {
        get { return sttDelegate.maxCharacter }
        set { sttDelegate.maxCharacter = newValue }
    }
    
    public var PlaceHolder: String {
        get { return placeHolder! } // tyt force unwrap lol
        set {
            if placeHolder != nil && isInitialized! {
                fatalError("Placeholder must be initialize only one time and before textView appearing on screen")
            }
            placeHolder = newValue
        }
    }
  //  public func SttTextView() { }
    
    
    override open var text: String! {
        get {
            return enabledPlaceholder ? "" : super.text
        }
        set {
            if String.isEmpty(newValue) {
                enabledPlaceholder = true
                super.text = ""
                super.text = PlaceHolder
                textColor = placeHolderColor
            }
            else if enabledPlaceholder && newValue != PlaceHolder {
                enabledPlaceholder = false
                super.text = newValue.replacingOccurrences(of: PlaceHolder, with: "")
                textColor = .black
              //self.text = newValue.replacingCharacters(in: PlaceHolder, with: "")
            }
        }
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        if delegate == nil {
            sttDelegate = SttHandlerTextView()
            delegate = sttDelegate
        }
        
        if let _delegate = self.delegate as? SttHandlerTextView {
            
            _delegate.addTarget(type: .selectionChanged, delegate: self) { (view, textView) in
            
                if super.text == view.PlaceHolder {
                    view.selectedRange = NSRange(location: 0, length: 0)
                }
            }
            
            _delegate.addTarget(type: .didEndEditing, delegate: self) { (view, textView) in
                if String.isEmpty( super.text) {
                    super.text = view.PlaceHolder
                    view.enabledPlaceholder = true
                    view.textColor = view.placeHolderColor
                }
            }
            
            _delegate.addTarget(type: .editing, delegate: self) { (view, textView) in
                if String.isEmpty(super.text) {
                    view.enabledPlaceholder = true
                    super.text = view.PlaceHolder
                    view.textColor = view.placeHolderColor
                }
                else if view.enabledPlaceholder && super.text != view.PlaceHolder {
                    view.enabledPlaceholder = false
                    super.text = super.text.replacingOccurrences(of: view.PlaceHolder, with: "")
                    view.textColor = .black
                }
            }
        }
    }
    
   // open override var
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if String.isWhiteSpace(super.text) {
            super.text = self.PlaceHolder
            textColor = placeHolderColor
        }
        else {
            enabledPlaceholder = false
        }
        
        enabledPlaceholder = super.text == PlaceHolder
        isInitialized = true
    }
    
}
