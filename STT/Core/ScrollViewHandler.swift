//
//  ScrollViewHandler.swift
//  STT
//
//  Created by Peter Standret on 9/15/19.
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

public enum ScrollViewActionType {
    case scrollViewDidScroll
    case scrollViewDidEndDecelerating
}

public protocol ScrollViewHandlerType {
    func handle(_ scrollView: UIScrollView)
}

///
/// Special object to track bottom scrolling position in table. Use for paggination
///
open class EndScrollHandler<Target: UIScrollView>: ScrollViewHandlerType {
    
    private var handlers = [SafeDelegatedCall<Target>]()
    
    open var callBackEndPixel: Int = 150
    
    public init() { }
    public init<T: AnyObject>(delegate: T, _ handler: @escaping (T, Target) -> Void, callBackEndPixel: Int = 150) {
        self.callBackEndPixel = callBackEndPixel
        handlers.append(SafeDelegatedCall(to: delegate, with: handler))
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

///
/// Special object to track top scrolling position in table. Use for paggination
///
open class TopScrollHandler<Target: UIScrollView>: ScrollViewHandlerType {
    
    private var handlers = [SafeDelegatedCall<Target>]()
    
    open var callBackEndPixel: Int = 150
    
    public init() { }
    public init<T: AnyObject>(delegate: T, _ handler: @escaping (T, Target) -> Void, callBackEndPixel: Int = 150) {
        self.callBackEndPixel = callBackEndPixel
        handlers.append(SafeDelegatedCall(to: delegate, with: handler))
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

open class ScrollViewHandler: NSObject, UIScrollViewDelegate {
    
    public var container = [ScrollViewActionType: [ScrollViewHandlerType]]()
    
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

extension ScrollViewHandler {
    
    ///
    /// Add end scrolled handler
    ///
    public func addEndScrollHandler<T: UIViewController>(delegate: T, callback: @escaping (T) -> Void, callBackEndPixel: Int = 150) {
        self.container[.scrollViewDidScroll] = self.container[.scrollViewDidScroll] ?? [ScrollViewHandlerType]()
        self.container[.scrollViewDidScroll]!.append(
            EndScrollHandler(
                delegate: delegate,
                { (delegate, _) in callback(delegate) },
                callBackEndPixel:  callBackEndPixel
            )
        )
    }
    
    ///
    /// Add top scrolled handler
    ///
    public func addTopScrollHandler<T: UIViewController>(delegate: T, callback: @escaping (T) -> Void, callBackEndPixel: Int = 150) {
        self.container[.scrollViewDidScroll] = self.container[.scrollViewDidScroll] ?? [ScrollViewHandlerType]()
        self.container[.scrollViewDidScroll]!.append(
            TopScrollHandler(
                delegate: delegate,
                { (delegate, _) in callback(delegate) },
                callBackEndPixel: callBackEndPixel
            )
        )
    }
}
