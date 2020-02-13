//
//  SttWallIndicatorView.swift
//  STT
//
//  Created by Piter Standret on 1/12/19.
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

public class SttWalIndicatorView: UIView {
    
    private var indicator: UIActivityIndicatorView!
    
    public var indicatorStyle: UIActivityIndicatorView.Style {
        get { return indicator.style }
        set { indicator.style = newValue }
    }
    public var indicatorColor: UIColor {
        get { return indicator.color }
        set { indicator.color = newValue }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        viewDidLoad()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        viewDidLoad()
    }
    
    private func viewDidLoad() {
        
        indicator = self.setIndicator()
        indicator.hidesWhenStopped = true
    }
    
    func startAnimating() {
        indicator.startAnimating()
        self.isHidden = false
    }
    
    func stopAnimating() {
        indicator.stopAnimating()
        self.isHidden = true
    }
}
