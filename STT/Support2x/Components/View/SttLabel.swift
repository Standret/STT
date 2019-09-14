//
//  SttLabel.swift
//  STT
//
//  Created by Peter Standret on 1/29/19.
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

open class SttLabel: UILabel {
    
    @objc
    open dynamic var highlightedFont: UIFont? {
        didSet {
            if isHighlighted {
                self.font = highlightedFont
                self.setNeedsDisplay()
            }
        }
    }
    
    @objc
    open dynamic var usualFont: UIFont? {
        didSet {
            if !isHighlighted {
                self.font = usualFont
                self.setNeedsDisplay()
            }
        }
    }
    
    override open var isHighlighted: Bool {
        didSet {
            self.setNeedsDisplay()
            if isHighlighted {
                self.font = highlightedFont
            }
            else {
                self.font = usualFont
            }
        }
    }
}
