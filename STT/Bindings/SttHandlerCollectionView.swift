//
//  SttHandlerCollectionView.swift
//  STT
//
//  Created by Peter Standret on 5/8/19.
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

public enum SttTypeActionScrollView {
    case scrollViewDidScroll
    case scrollViewDidEndDecelerating
}

public protocol SttScrollViewHandlerType {
    func handle(_ scrollView: UIScrollView)
}

open class SttEndScrollHandler<Target: UIScrollView>: SttScrollViewHandlerType {
    
    private var handlers = [SttDelegatedCall<Target>]()
    
    open var callBackEndPixel: Int = 150
    
    public init() { }
    public init<T: AnyObject>(delegate: T, _ handler: @escaping (T, Target) -> Void, callBackEndPixel: Int = 150) {
        self.callBackEndPixel = callBackEndPixel
        handlers.append(SttDelegatedCall(to: delegate, with: handler))
    }
    
    private var inPosition: Bool = false
    open func handle(_ scrollView: UIScrollView) {
        
        let y = scrollView.contentOffset.y
        let height = scrollView.contentSize.height - scrollView.bounds.height - CGFloat(callBackEndPixel)
        
        if (scrollView.contentSize.height > scrollView.bounds.height) {
            if (y > height) {
                if (!inPosition) {
                    handlers.forEach({ $0.callback(scrollView as! Target) })
                }
                inPosition = true
            }
            else {
                inPosition = false
            }
        }
    }
}

open class SttTopScrollHandler<Target: UIScrollView>: SttScrollViewHandlerType {
    
    private var handlers = [SttDelegatedCall<Target>]()
    
    open var callBackEndPixel: Int = 150
    
    public init() { }
    public init<T: AnyObject>(delegate: T, _ handler: @escaping (T, Target) -> Void, callBackEndPixel: Int = 150) {
        self.callBackEndPixel = callBackEndPixel
        handlers.append(SttDelegatedCall(to: delegate, with: handler))
    }
    
    private var inPosition: Bool = false
    open func handle(_ scrollView: UIScrollView) {
        
        let y = Int(scrollView.contentOffset.y)
        
        if (scrollView.contentSize.height > scrollView.bounds.height) {
            if (y < callBackEndPixel) {
                if (!inPosition) {
                    handlers.forEach({ $0.callback(scrollView as! Target) })
                }
                
                inPosition = true
            }
            else {
                inPosition = false
            }
        }
    }
}
