//
//  SttBaseScrollSource.swift
//  STT
//
//  Created by Andriy Popel on 7/15/19.
//  Copyright © 2019 Andriy Popel <andriypopel@googlemail.com>
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

open class SttBaseScrollSource: NSObject, UIScrollViewDelegate {
    
    
    public var container = [SttTypeActionScrollView: [SttScrollViewHandlerType]]()
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.container[.scrollViewDidScroll]?.forEach({ $0.handle(scrollView) })
    }
    
    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) { }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) { }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) { }
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) { }
    
    open func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) { }
    
    open func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) { }
    
    open func scrollViewDidZoom(_ scrollView: UIScrollView) { }
    
    open func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) { }
    
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) { }
    
    open func scrollViewDidScrollToTop(_ scrollView: UIScrollView) { }
    
    open func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool { return true }
    
}

extension SttBaseScrollSource {
    
    /// Add end scrolled handler
    public func addEndScrollHandler<T: UIViewController>(delegate: T, callback: @escaping (T) -> Void, callBackEndPixel: Int = 150) {
        self.container[.scrollViewDidScroll] = self.container[.scrollViewDidScroll] ?? [SttScrollViewHandlerType]()
        self.container[.scrollViewDidScroll]!.append(
            SttEndScrollHandler(delegate: delegate, { (delegate, _) in callback(delegate) }, callBackEndPixel:  callBackEndPixel)
        )
    }
    
    /// Add top scrolled handler
    public func addTopScrollHandler<T: UIViewController>(delegate: T, callback: @escaping (T) -> Void, callBackEndPixel: Int = 150) {
        self.container[.scrollViewDidScroll] = self.container[.scrollViewDidScroll] ?? [SttScrollViewHandlerType]()
        self.container[.scrollViewDidScroll]!.append(
            SttTopScrollHandler(delegate: delegate, { (delegate, _) in callback(delegate) }, callBackEndPixel: callBackEndPixel)
        )
    }
}
