//
//  UIViewControllerDExt.swift
//  STT
//
//  Created by Standret on 5/13/18.
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

public extension UIViewController {
    
    ///
    /// Determine if current view controller war presenter as modal
    ///
    var isModal: Bool {
        if let index = navigationController?.viewControllers.firstIndex(of: self), index > 0 {
            return false
        } else if presentingViewController != nil {
            return true
        } else if navigationController?.presentingViewController?.presentedViewController == navigationController  {
            return true
        } else if tabBarController?.presentingViewController is UITabBarController {
            return true
        } else {
            return false
        }
    }
}

// MARK: - obsoleted block

public extension UIViewController {
    
    @available(swift, deprecated: 5.0, message: "This will be removed in v5.1")
    func createAlerDialog(title: String?, message: String, buttonTitle: String? = nil, handlerOk: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: buttonTitle ?? "Ok", style: .cancel, handler: { (action) in
            self.resignFirstResponder()
            handlerOk?()
        }))
        if let popover = alertController.popoverPresentationController {
            popover.sourceView = self.view
            popover.permittedArrowDirections = .up
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @available(swift, deprecated: 5.0, message: "This will be removed in v5.1")
    func createDecisionAlerDialog(title: String?, message: String, buttonTrueTitle: String? = nil, buttonFalseTitle: String? = nil, handlerOk: (() -> Void)? = nil, handlerFalse: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: buttonTrueTitle ?? "Yes", style: .cancel, handler: { (action) in
            handlerOk?()
        }))
        alertController.addAction(UIAlertAction(title: buttonFalseTitle ?? "Cancel", style: .default, handler: { (action) in
            self.resignFirstResponder()
            handlerFalse?()
        }))
        if let popover = alertController.popoverPresentationController {
            popover.sourceView = self.view
            popover.permittedArrowDirections = .up
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
}
