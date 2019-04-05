//
//  DisableButton.swift
//  STT
//
//  Created by Grimm on 12/14/18.
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

public class SttDisableButton: SttButton {
    
    @objc
    dynamic public var activeColor: UIColor? {
        didSet {
            if isEnabled {
                backgroundColor = activeColor
            }
        }
    }
    @objc
    dynamic public var disableColor: UIColor? {
        didSet {
            if !isEnabled {
                backgroundColor = disableColor
            }
        }
    }
    
    @objc
    dynamic public var activeTintColor: UIColor? {
        didSet {
            if isEnabled {
                tintColor = activeTintColor
            }
        }
    }
    @objc
    dynamic public var disableTintColor: UIColor? {
        didSet {
            if !isEnabled {
                tintColor = disableTintColor
            }
        }
    }
    
    override public var isEnabled: Bool {
        didSet {
            if isEnabled {
                backgroundColor = activeColor
                tintColor = activeTintColor
            }
            else {
                backgroundColor = disableColor
                tintColor = disableTintColor
            }
        }
    }
}
