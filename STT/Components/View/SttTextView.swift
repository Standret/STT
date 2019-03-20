//
//  SttTextView.swift
//  STT
//
//  Created by Andriy Popel on 3/20/19.
//  Copyright © 2019 standret. All rights reserved.
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
    
    private var sttDelegate: SttHandlerTextView!
    
    private var placeHolder: String?
    var isInitialized: Bool?
    var enabledPlaceholder = true
    
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
            if SttString.isEmpty(string: newValue) {
                enabledPlaceholder = true
                super.text = ""
                super.text = PlaceHolder
                textColor = PlaceHolderColor
            }
            else if enabledPlaceholder && newValue != PlaceHolder {
                enabledPlaceholder = false
                super.text = newValue.replacingOccurrences(of: PlaceHolder, with: "")
                textColor = .black
              //self.text = newValue.replacingCharacters(in: PlaceHolder, with: "")
            }
        }
    }
    
    public var PlaceHolderColor: UIColor = .lightGray
    
    public var MaxLength = Int32.max
    
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
                if SttString.isEmpty(string: super.text) {
                    super.text = view.PlaceHolder
                    view.enabledPlaceholder = true
                    view.textColor = view.PlaceHolderColor
                }
            }
            
            _delegate.addTarget(type: .editing, delegate: self) { (view, textView) in
                if SttString.isEmpty(string: super.text) {
                    view.enabledPlaceholder = true
                    super.text = view.PlaceHolder
                    view.textColor = view.PlaceHolderColor
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
        
        if SttString.isWhiteSpace(string: super.text) {
            super.text = self.PlaceHolder
            textColor = PlaceHolderColor
        }
        else {
            enabledPlaceholder = false
        }
        
        enabledPlaceholder = super.text == PlaceHolder
        isInitialized = true
    }
    
}
