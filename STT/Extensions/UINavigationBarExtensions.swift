//
//  UINavigationBarExtensions.swift
//  STT
//
//  Created by Peter Standret on 9/14/19.
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

public extension UINavigationBar {
    
    ///
    /// Make navigation bar transparent.
    /// - Parameter tint: tint color if nil set nothing
    ///
    func makeTransparent(withTint tint: UIColor? = nil) {
        var titleAttributes: [NSAttributedString.Key: Any]?
        if let tint = tint {
            titleAttributes = [
               .foregroundColor: tint as Any,
           ]
        }
        
        self.isTranslucent = true
        if #available(iOS 13.0, *) {
            if let titleAttributes = titleAttributes {
                self.standardAppearance.titleTextAttributes = titleAttributes
                self.standardAppearance.largeTitleTextAttributes = titleAttributes
            }
            self.standardAppearance.backgroundColor = .clear
            self.standardAppearance.backgroundEffect = nil
            self.standardAppearance.shadowColor = .clear
            self.standardAppearance.shadowImage = UIImage()
            self.standardAppearance.backgroundImage = UIImage()
        } else {
            if let titleAttributes = titleAttributes {
                self.tintColor = tint
                self.largeTitleTextAttributes = titleAttributes
            }
            self.backgroundColor = .clear
            self.barTintColor = .clear
            self.setBackgroundImage(UIImage(), for: .default)
            self.shadowImage = UIImage()
        }
    }
}
