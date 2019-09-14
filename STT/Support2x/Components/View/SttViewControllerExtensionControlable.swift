//
//  SttViewControllerExtensionControlable.swift
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

extension SttViewController: SttViewControlable {
    
    public func sendError(error: SttBaseErrorType) {
        let serror = error.getMessage()
        if useErrorLabel {
            viewError.showMessage(text: serror.0, detailMessage: serror.1)
        }
        else {
            self.createAlerDialog(title: serror.0, message: serror.1)
        }
        
        if useVibrationOnError {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }
    public func sendError(title: String, description: String) {
        if useErrorLabel {
            viewError.showMessage(text: title, detailMessage: description)
        }
        else {
            self.createAlerDialog(title: title, message: description)
        }
        if useVibrationOnError {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }
    public func sendMessage(title: String, message: String?) {
        if useErrorLabel {
            viewError.showMessage(text: title, detailMessage: message, isError: false)
        }
        else {
            self.createAlerDialog(title: title, message: message ?? "")
        }
    }
}
