//
//  SttInputBox.swift
//  STT
//
//  Created by Standret on 12/13/18.
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
import RxSwift

public enum TypeInputBox {
    case text
    case security(TypeShpwPassword)
}

public enum TypeShpwPassword {
    case none
    case eye
    case text
}

open class SttInputBox: UIView, SttViewable {
    
    public private(set) var textField: SttTextField!
    
    private var disposeBag = DisposeBag()
    
    private(set) public var icon: UIImageView!
    private(set) public var showButton: SttButton!
    
    private(set) public var label: UILabel!
    private(set) public var errorLabel: UILabel!
    private(set) public var underline: UIView!
    
    private(set) public var isEdited = false
    
    private var textsLeft = [NSLayoutConstraint]()
    private var textsRight = [NSLayoutConstraint]()
    private var cnstrtfToRight: NSLayoutConstraint!
    
    public private(set) lazy var textFieldHandler = SttHandlerTextField(self.textField)
    
    private var cnstrUnderlineHeight: NSLayoutConstraint!
    private var cnstrErrorHeight: NSLayoutConstraint!
    private var cnstrRightIconTF, cnstrRightButtonTF: NSLayoutConstraint!
    /// disable or enable all start and end editing animation
    public  var isAnimate: Bool = true
    
    public  var isError: Bool { return !SttString.isWhiteSpace(string: error) }
    
    @objc
    dynamic public var textEdges: UIEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8) {
        didSet {
            
            label.frame = CGRect(x: textEdges.left, y: label.frame.origin.y, width: label.frame.width, height: label.frame.height)
            
            for litem in textsLeft {
                litem.constant = textEdges.left
            }
            
            for ritem in textsRight {
                ritem.constant = -textEdges.right
            }
        }
    }
    
    @IBInspectable
    public var labelName: String? {
        get { return label.text }
        set { label.text = newValue }
    }
    
    @objc
    dynamic public var isSimpleLabel: Bool = false {
        didSet {
            label.isHidden = isSimpleLabel
            textField.placeholder = isSimpleLabel ? label.text : ""
        }
    }
    
    @objc
    dynamic public var useVibrationOnError = false
    
    public var typeInputBox: TypeInputBox = .text {
        didSet {
            changeType(type: typeInputBox)
        }
    }
    
    public var text: String? {
        get { return textField.text }
        set {
            if !isEdited {
                startEditing()
            }
            
            textField.text = newValue
        }
    }
    
    open var error: String? {
        didSet {
            
            if !SttString.isWhiteSpace(string: error) {
                underline.backgroundColor = errorColor
                if useVibrationOnError && SttString.isWhiteSpace(string: errorLabel.text) {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                }
            }
            else {
                underline.backgroundColor = isEdited ? underlineActiveColor : underlineDisableColor
                label.textColor = isEdited ? labelActiveColor : labelDisableColor
            }
            
            errorLabel.text = error
        }
    }
    
    // MARK: Appereance
    @objc dynamic public var textFieldFont: UIFont? {
        get { return textField.font }
        set { textField.font = newValue }
    }
    @objc dynamic public var labelFont: UIFont? {
        get { return label.font }
        set { label.font = newValue }
    }
    @objc dynamic public var errorLabelFont: UIFont? {
        get { return errorLabel.font }
        set { errorLabel.font = newValue }
    }
    
    @objc dynamic public var textFieldColor: UIColor? {
        get { return textField.textColor }
        set { if SttString.isEmpty(string: text) { textField.textColor = newValue } }
    }
    @objc dynamic public var errorColor: UIColor? {
        get { return errorLabel.textColor }
        set { errorLabel.textColor = newValue }
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
    
    @objc dynamic public var showButtonShowText: String? {
        get { return showButton.title(for: .normal) }
        set { showButton.setTitle(newValue, for: .normal) }
    }
    @objc dynamic public var showButtonHideText: String? {
        get { return showButton.title(for: .normal) }
        set { showButton.setTitle(newValue, for: .selected) }
    }
    
    @objc dynamic public var fontShowButton: UIFont {
        get { return showButton.titleFont }
        set { showButton.titleFont = newValue }
    }
    
    @objc dynamic public var titleShowColorShowButton: UIColor? {
        get { return showButton.titleColor(for: .normal) }
        set { showButton.setTitleColor(newValue, for: .normal) }
    }
    @objc dynamic public var titleHideShowButton: UIColor? {
        get { return showButton.titleColor(for: .normal) }
        set { showButton.setTitleColor(newValue, for: .selected) }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        viewDidLoad()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        viewDidLoad()
    }
    
    @discardableResult
    override open func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    public func setAttributedString(string: NSAttributedString) {
        textField.attributedText = string
        if !SttString.isEmpty(string: text) {
            startEditing()
        }
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
        
        if SttString.isEmpty(string: textField.text) {
            UIView.animate(withDuration: isAnimate ? 0.3 : 0) {
                self.label.transform = CGAffineTransform.identity
            }
        }
        
        cnstrUnderlineHeight.constant = underlineDisableHeight
        UIView.animate(withDuration: isAnimate ? 0.3 : 0, animations: { self.layoutIfNeeded() })
    }
    
    open func viewDidLoad() {
        
        initTextField()
        initIcon()
        initButtonShow()
        initLabel()
        initUnderline()
        initError()
        
        changeType(type: typeInputBox)
    }
    
    private func initTextField() {
        
        textField = SttTextField()
        textField.borderStyle = .none
        textField.keyboardType = .asciiCapable
        textField.textAlignment = .left
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = textFieldHandler
        textField.clearButtonMode = .never
        textField.height(40)
        
        textField.textChanged
            .subscribe(onNext: { [weak self] in
                guard let _self = self else { return }
                
                if !SttString.isEmpty(string: $0) && !_self.textField.isEditing  {
                    _self.startEditing()
                }
                else if !_self.textField.isEditing {
                    _self.endEditing()
                }
            }).disposed(by: disposeBag)
        
        if #available(iOS 12, *) {
            textField.textContentType = .oneTimeCode
        } else {
            textField.textContentType = .init(rawValue: "")
        }

        addSubview(textField)
        
        textField.topToSuperview(offset: 19)
        textsLeft.append(textField.leftToSuperview(offset: textEdges.left))
        
        cnstrtfToRight = textField.rightToSuperview(offset: textEdges.right)
        textsRight.append(cnstrtfToRight)
        
        textFieldHandler.addTarget(type: .didStartEditing, delegate: self,
                                   handler: { (v, _) in v.startEditing() })
        textFieldHandler.addTarget(type: .didEndEditing, delegate: self,
                                   handler: { (v, _) in v.endEditing() })
    }
    
    private func initIcon() {
        icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.image = UIImage(named: "eye_open")
        icon.isUserInteractionEnabled = true
        icon.contentMode = .center

        icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickShowHandler(_:))))

        addSubview(icon)

        icon.height(22)
        icon.width(22)
        icon.centerY(to: textField)

        cnstrtfToRight.isActive = false
        cnstrRightIconTF = icon.leftToRight(of: textField, offset: 2, priority: LayoutPriority(rawValue: 750))
        textsRight.append(icon.rightToSuperview(offset: -(textEdges.right + 2)))
    }
    private func initButtonShow() {
        showButton = SttButton()
        showButton.translatesAutoresizingMaskIntoConstraints = false
        showButton.tintColor = .clear
        
        addSubview(showButton)
        
        showButton.height(30)
        showButton.width(50, relation: .equal)
        showButton.centerY(to: textField)
        
        cnstrtfToRight.isActive = false
        cnstrRightButtonTF = showButton.leftToRight(of: textField, offset: 2, priority: LayoutPriority(rawValue: 750))
        textsRight.append(showButton.rightToSuperview(offset: -(textEdges.right + 2)))
        
        showButton.addTarget(self, action: #selector(clickShowHandler(_:)), for: .touchUpInside)
    }
    
    private func initLabel() {
        label = UILabel(frame: CGRect(x: textEdges.left, y: 25, width: 300, height: 22))
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
        underline.topToBottom(of: textField, offset: 5)
    }
    private func initError() {
        errorLabel = UILabel()
        errorLabel.textAlignment = .left
        errorLabel.numberOfLines = 3
        errorLabel.textColor = .red
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.text = ""
        cnstrErrorHeight = errorLabel.height(0, relation: .equalOrGreater)
        
        addSubview(errorLabel)
        
        errorLabel.bottomToSuperview(offset: 3)
        textsLeft.append(errorLabel.leftToSuperview(offset: textEdges.left))
        textsRight.append(errorLabel.rightToSuperview(offset: textEdges.right))
        errorLabel.topToBottom(of: underline, offset: 2)
    }
    
    @objc private func clickShowHandler(_ sender: Any) {
        
        switch typeInputBox {
        case .security(let type):
            textField.isSecureTextEntry.toggle()
            switch type {
            case .eye:
                icon.image = textField.isSecureTextEntry ? UIImage(named: "eye_open") : UIImage(named: "eye_close")
            default:
                showButton.isSelected.toggle()
            }
        default:
            textField.becomeFirstResponder()
        }
    }
    
    private func changeType(type: TypeInputBox) {
        textField.isSecureTextEntry = false
        textField.isUserInteractionEnabled = true
        cnstrtfToRight.isActive = true
        
        icon.isHidden = true
        showButton.isHidden = true
        cnstrRightButtonTF.isActive = false
        cnstrRightIconTF.isActive = false
        
        switch type {
        case .text: break;
        case .security(let type):
            switch type {
                
            case .none: break
            case .eye:
                cnstrtfToRight.isActive = false
                icon.isHidden = false
                cnstrRightIconTF.isActive = true
            case .text:
                cnstrtfToRight.isActive = false
                showButton.isHidden = false
                cnstrRightButtonTF.isActive = true
            }
            
            textField.isSecureTextEntry = true
        }
    }
}
