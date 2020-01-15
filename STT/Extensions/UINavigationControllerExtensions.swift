//
//  UINavigationControllerExtensions.swift
//  STT
//
//  Created by Piter Standret on 7/23/18.
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

import UIKit

public extension UINavigationController {
    
    ////
    /// Pops particular view controllers until the specified view controller is at the top of the navigation stack.
    /// - Parameter ofClass: type of class
    /// - Parameter animated: is pop animated
    ///
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.filter({ $0.isKind(of: ofClass) }).last {
            popToViewController(vc, animated: animated)
        }
    }
    
    ////
    /// Pops last N view controllers particular from the navigation stack.
    /// - Parameter viewsToPop: count of view to delete from navigation stack
    /// - Parameter animated: is pop animated
    ///
    func popViewControllers(viewsToPop: Int, animated: Bool = true) {
        if viewControllers.count > viewsToPop {
            let vc = viewControllers[viewControllers.count - viewsToPop - 1]
            popToViewController(vc, animated: animated)
        }
    }
}

// MARK: - obsoleted block

public extension UINavigationController {
    
    @available(swift, deprecated: 5.0, obsoleted: 5.1, message: "This will be removed in v5.1")
    var shadowColor: CGColor? {
        get { return self.navigationBar.layer.shadowColor }
        set(value) {
            self.navigationBar.layer.masksToBounds = false
            self.navigationBar.layer.shadowColor = value
            self.navigationBar.layer.shadowOpacity = 0.6
            self.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 0.5)
            self.navigationBar.layer.shadowRadius = 0.5
        }
    }
    
    @available(swift, obsoleted: 5.0, message: "method was moved to UINavigationBar.makeTransparent")
    func createTransparent() {
        self.navigationBar.isTranslucent = true
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
    }
}
