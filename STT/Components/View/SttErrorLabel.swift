//
//  SttErrorLabel.swift
//  STT
//
//  Created by Piter Standret on 6/22/18.
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

public class SttErrorLabel: UIView {
    
    private var errorLabel: UILabel!
    private var topContraint: NSLayoutConstraint!
    private var detailMessage: String?
    
    public var errorColor: UIColor! = UIColor.red
    public var messageColor: UIColor! = UIColor.green
    
    public weak var delegate: UIViewController! {
        didSet {
            injectConponnent()
        }
    }
    
    @objc
    public dynamic var heightErrorLabel: CGFloat = 40
    @objc
    public dynamic var textColor: UIColor? {
        didSet {
            errorLabel.textColor = textColor
        }
    }
    @objc
    public dynamic var textFont: UIFont? {
        didSet {
            errorLabel.font = textFont
        }
    }
    
    public func showMessage(text: String, detailMessage: String?, isError: Bool = true) {
        DispatchQueue.main.async {
            self.detailMessage = detailMessage
            self.errorLabel.text = text
            self.isHidden = false
            self.backgroundColor = isError ? self.errorColor : self.messageColor
            UIView.animate(withDuration: 0.5, animations: { self.alpha = 1 })
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (timer) in
                timer.invalidate()
                UIView.animate(withDuration: 0.5, animations: { self.alpha = 0 })
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
                    timer.invalidate()
                    self.isHidden = true
                }
            }
        }
    }
    
    @objc
    private func onClick(_ sender: Any) {
        if let message = detailMessage {
            delegate.createAlerDialog(title: errorLabel.text, message: message)
        }
    }
    
    private func injectConponnent() {
        translatesAutoresizingMaskIntoConstraints = false
        delegate.view.addSubview(self)
        topContraint = self.topAnchor.constraint(equalTo: delegate.view.safeTopAnchor)
        self.safeLeftAnchor.constraint(equalTo: delegate.view.safeLeftAnchor).isActive = true
        self.safeRightAnchor.constraint(equalTo: delegate.view.safeRightAnchor).isActive = true
        self.addConstraint(NSLayoutConstraint(item: self,
                                              attribute: NSLayoutConstraint.Attribute.height,
                                              relatedBy: NSLayoutConstraint.Relation.equal,
                                              toItem: nil,
                                              attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                              multiplier: 1,
                                              constant: heightErrorLabel))
        
        topContraint.isActive = true
        self.alpha = 0
        self.isHidden = true
        
        errorLabel = UILabel()
        errorLabel.textColor = UIColor.white
        errorLabel.font = UIFont.systemFont(ofSize: 14)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.textAlignment = .center
        
        self.addSubview(errorLabel)
        self.addConstraints([
            NSLayoutConstraint(item: self,
                               attribute: NSLayoutConstraint.Attribute.centerX,
                               relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: errorLabel,
                               attribute: NSLayoutConstraint.Attribute.centerX,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: self,
                               attribute: NSLayoutConstraint.Attribute.centerY,
                               relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: errorLabel,
                               attribute: NSLayoutConstraint.Attribute.centerY,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: self,
                               attribute: NSLayoutConstraint.Attribute.left,
                               relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: errorLabel,
                               attribute: NSLayoutConstraint.Attribute.left,
                               multiplier: 1,
                               constant: -15),
            NSLayoutConstraint(item: self,
                               attribute: NSLayoutConstraint.Attribute.right,
                               relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: errorLabel,
                               attribute: NSLayoutConstraint.Attribute.right,
                               multiplier: 1,
                               constant: 15)
            ])
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClick(_:))))
    }
}
