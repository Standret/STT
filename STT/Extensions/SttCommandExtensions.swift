//
//  SttCommandExtensions.swift
//  STT
//
//  Created by Standret on 26.05.18.
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
import RxSwift
import UIKit

public extension Observable {
    
    func useWork(_ command: SttCommandType) -> Observable<Element> {
        return command.useWork(observable: self)
    }
}

public extension SttCommandType {
    
    @discardableResult
    func useIndicator(
        button: UIButton,
        style: UIActivityIndicatorView.Style = .gray,
        color: UIColor = .gray
        ) -> Disposable {
        
        let indicator = button.setIndicator()
        indicator.color = color
        indicator.style = style
        indicator.setNeedsLayout()
        
        let title = button.titleLabel?.text
        var image, disImage: UIImage?
        
        return self.useWork(start: {
            image = button.image(for: .normal)
            disImage = button.image(for: .disabled)
            button.setImage(nil, for: .normal)
            button.setImage(nil, for: .disabled)
            button.setTitle("", for: .disabled)
            button.isEnabled = false
            indicator.startAnimating()
        }) {
            button.setImage(image, for: .normal)
            button.setImage(disImage, for: .disabled)
            button.setTitle(title, for: .disabled)
            button.setNeedsDisplay()
            button.isEnabled = true
            indicator.stopAnimating()
        }
    }
    
    @discardableResult
    func useIndicator(
        view:  UIView,
        style: UIActivityIndicatorView.Style = .gray,
        color: UIColor = .gray
        ) -> Disposable {
        
        let indicator = view.setIndicator()
        indicator.color = color
        indicator.style = style
        indicator.setNeedsLayout()
        
        return self.useWork(start: {
            indicator.startAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }) {
            indicator.stopAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    @discardableResult
    func useRefresh(scrollView: UIScrollView, parameter: Any? = nil) -> (disposable: Disposable, refreshControl: UIRefreshControl) {
        let refreshControl = SttRefreshControl()
        scrollView.refreshControl = refreshControl
        return (disposable: refreshControl.useCommand(self, parameter: parameter), refreshControl: refreshControl)
    }
}
