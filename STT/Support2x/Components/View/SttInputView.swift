//
//  InputView.swift
//  STT
//
//  Created by Piter Standret on 12/19/18.
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
import TinyConstraints

@IBDesignable
open class SttInputView: UIView, SttViewable {
    
    private(set) public var textView: UITextView!
    private(set) public var label: UILabel!
    private(set) public var counterLabel: UILabel!
    private(set) public var errorLabel: UILabel!
    private(set) public var underline: UIView!
    
    private(set) public var isEdited = false
    
    private var cnstrUnderlineHeight: NSLayoutConstraint!
    private var cnstrErrorHeight: NSLayoutConstraint!
    
    public let handlerTextView = SttHandlerTextView()
    
    public var isAnimate: Bool = true
    
    public var isError: Bool { return !String.isWhiteSpace(error)}
    
    @IBInspectable
    public var labelName: String? {
        get { return label.text }
        set { label.text = newValue }
    }
    
    @objc
    dynamic public var useVibrationOnError = false
    
    @objc
    dynamic public var maxCount: Int = 70 {
        didSet {
            handlerTextView.maxCharacter = maxCount
            changeCounterValue(to: 0)
        }
    }
    
    open var error: String? {
        didSet {
            errorLabel.text = error
            
            if !String.isWhiteSpace(error) {
                underline.backgroundColor = errorColor
//                if isEdited {
//                    label.textColor = errorColor
//                }
                if useVibrationOnError {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                }
                
            }
            else {
                underline.backgroundColor = isEdited ? underlineActiveColor : underlineDisableColor
                label.textColor = isEdited ? labelActiveColor : labelDisableColor
            }
        }
    }
    
    // MARK: Appereance
    @objc dynamic public var textFieldFont: UIFont? {
        get { return textView.font }
        set { textView.font = newValue }
    }
    @objc dynamic public var labelFont: UIFont? {
        get { return label.font }
        set { label.font = newValue }
    }
    @objc dynamic public var errorLabelFont: UIFont? {
        get { return errorLabel.font }
        set { errorLabel.font = newValue }
    }
    @objc dynamic public var counterLabelFont: UIFont? {
        get { return counterLabel.font }
        set { counterLabel.font = newValue }
    }
    
    @objc dynamic public var textFieldColor: UIColor? {
        get { return textView.textColor }
        set { textView.textColor = newValue }
    }
    @objc dynamic public var errorColor: UIColor? {
        get { return errorLabel.textColor }
        set { errorLabel.textColor = newValue }
    }
    @objc dynamic public var counterColor: UIColor? {
        get { return counterLabel.textColor }
        set { counterLabel.textColor = newValue }
    }
    
    @objc dynamic public var labelActiveColor: UIColor = .black
    @objc dynamic public var labelDisableColor: UIColor = .black {
        didSet {
            if !isError {
                label.textColor = labelDisableColor
            }
        }
    }
    
    @objc dynamic public var underlineActiveColor: UIColor = .black
    @objc dynamic public var underlineDisableColor: UIColor = .black {
        didSet {
            if !isError && !isEdited {
                underline.backgroundColor = underlineDisableColor
            }
        }
    }
    
    @objc dynamic public var underlineActiveHeight: CGFloat = 2 {
        didSet {
            if isEdited {
                cnstrUnderlineHeight.constant = underlineActiveHeight
            }
        }
    }
    @objc dynamic public var underlineDisableHeight: CGFloat = 0.5 {
        didSet {
            if !isEdited {
                cnstrUnderlineHeight.constant = underlineDisableHeight
            }
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        viewDidLoad()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        viewDidLoad()
    }
    
    override open func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }
    
    open func viewDidLoad() {
        
        initTextView()
        initLabel()
        initUnderline()
        initCounter()
        initError()
    }
    
    private func initTextView() {
        
        textView = UITextView()
        textView.textAlignment = .left
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.autocorrectionType = .no
        textView.isScrollEnabled = false
        textView.delegate = handlerTextView
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        addSubview(textView)
        
        textView.edgesToSuperview(excluding: .bottom, insets: .top(14) + .left(-4) + .right(-4))
        
        handlerTextView.addTarget(type: .didBeginEditing, delegate: self,
                                  handler: { (v, _) in v.startEditing() })
        handlerTextView.addTarget(type: .didEndEditing, delegate: self,
                                  handler: { (v, _) in v.endEditing() })
        handlerTextView.addTarget(type: .editing, delegate: self,
                                  handler: { (v, tv) in
                                    self.changeCounterValue(to: self.textView.text.count)
                                    self.layoutIfNeeded()
                                    
                                    if !String.isEmpty(tv.text) { v.startEditing() }
                                    if !tv.isFirstResponder { v.endEditing() } })
    }
    private func initLabel() {
        label = UILabel(frame: CGRect(x: 0, y: 25, width: 300, height: 22))
        label.textAlignment = .left
        label.text = "Field"
        addSubview(label)
    }
    private func initUnderline() {
        underline = UIView()
        underline.translatesAutoresizingMaskIntoConstraints = false
        underline.backgroundColor = underlineDisableColor
        
        cnstrUnderlineHeight = underline.height(underlineDisableHeight)
        
        addSubview(underline)
        underline.edgesToSuperview(excluding: [.top, .bottom])
        underline.topToBottom(of: textView, offset: 5)
    }
    private func initCounter() {
        counterLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 22))
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        counterLabel.text = "59/60"
        counterLabel.textAlignment = .right

        counterLabel.height(22)
        
        addSubview(counterLabel)
        
        counterLabel.edgesToSuperview(excluding: [.top, .left], insets: .bottom(3) + .right(0))
        
        changeCounterValue(to: maxCount)
    }
    private func initError() {
        errorLabel = UILabel()
        errorLabel.textAlignment = .left
        errorLabel.numberOfLines = 3
        errorLabel.textColor = .red
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.text = ""
        cnstrErrorHeight = errorLabel.height(22, relation: .equalOrGreater)
        
        addSubview(errorLabel)
        
        errorLabel.edgesToSuperview(excluding: [.right, .top], insets: .bottom(3) + .left(0))
        errorLabel.topToBottom(of: underline, offset: 2)
        errorLabel.rightToLeft(of: counterLabel)
    }
    
    open func startEditing() {
        isEdited = true
        
        label.textColor = labelActiveColor
        if isError {
            //label.textColor = errorColor
        }
        else {
            underline.backgroundColor = underlineActiveColor
        }
        
        UIView.animate(withDuration: isAnimate ? 0.3 : 0, animations: {
            
            let trans  = -(self.label.bounds.width - self.label.bounds.width * 0.575) / 2
            let translation = CGAffineTransform(translationX: trans, y: -25)
            let scaling = CGAffineTransform(scaleX: 0.575,
                                            y: 0.575)
            
            self.label.transform = scaling.concatenating(translation)
            
            self.cnstrUnderlineHeight.constant = self.underlineActiveHeight
            
            self.layoutIfNeeded()
        })
    }
    open func endEditing() {
        isEdited = false
        
        label.textColor = labelDisableColor
        if isError {
            //underline.backgroundColor = underlineDisableColor
            //label.textColor = labelDisableColor
        }
        else {
            underline.backgroundColor = underlineDisableColor
        }
        
        if String.isEmpty(textView.text) {
            UIView.animate(withDuration:  isAnimate ? 0.3 : 0) {
                self.label.transform = CGAffineTransform.identity
            }
        }
        
        cnstrUnderlineHeight.constant = underlineDisableHeight
        UIView.animate(withDuration:  isAnimate ? 0.3 : 0, animations: { self.layoutIfNeeded() })
    }
    
    private func changeCounterValue(to with: Int) {
        counterLabel.text = "\(with)/\(handlerTextView.maxCharacter)"
    }
}
