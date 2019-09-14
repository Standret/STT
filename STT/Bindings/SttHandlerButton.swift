//
//  SttHandlerButton.swift
//  OVS
//
//  Created by Peter Standret on 2/8/19.
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

public enum SttActionButton {
    case touchUpInside
    case touchUpOutside
    case touchDown
    case touchDragEnter
    case touchDragExit
    case touchCancel
}

public final class SttHandlerButton {
    
    private var handlers = [SttActionButton: [SttDelegatedCall<UIButton>]]()
    
    public init(_ button: UIButton) {
        button.addTarget(self, action: #selector(onTouchUpInside(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(onTouchUpOutside(_:)), for: .touchUpOutside)
        button.addTarget(self, action: #selector(onTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(onTouchDragEnter(_:)), for: .touchDragEnter)
        button.addTarget(self, action: #selector(onTouchDragExit(_:)), for: .touchDragExit)
        button.addTarget(self, action: #selector(onTouchCancel(_:)), for: .touchCancel)
    }
    
    public func addTarget<T: AnyObject>(type: SttActionButton, delegate: T, handler: @escaping (T, UIButton) -> Void) {
        
        handlers[type] = handlers[type] ?? [SttDelegatedCall<UIButton>]()
        handlers[type]?.append(SttDelegatedCall<UIButton>(to: delegate, with: handler))
    }
    
    public func addMultipleTargets<T: AnyObject>(type: [SttActionButton], delegate: T, handler: @escaping (T, UIButton) -> Void) {
        type.forEach({
            handlers[$0] = handlers[$0] ?? [SttDelegatedCall<UIButton>]()
            handlers[$0]?.append(SttDelegatedCall<UIButton>(to: delegate, with: handler))
        })
    }
    
    @objc
    private func onTouchUpInside(_ sender: UIButton) {
        handlers[.touchUpInside]?.forEach({ $0.callback(sender) })
    }
    
    @objc
    private func onTouchUpOutside(_ sender: UIButton) {
        handlers[.touchUpOutside]?.forEach({ $0.callback(sender) })
    }
    
    @objc private func onTouchDown(_ sender: UIButton) {
        handlers[.touchDown]?.forEach({ $0.callback(sender) })
    }
    
    @objc private func onTouchDragEnter(_ sender: UIButton) {
        handlers[.touchDragEnter]?.forEach({ $0.callback(sender) })
    }
    
    @objc private func onTouchDragExit(_ sender: UIButton) {
        handlers[.touchDragExit]?.forEach({ $0.callback(sender) })
    }
    
    @objc private func onTouchCancel(_ sender: UIButton) {
        handlers[.touchCancel]?.forEach({ $0.callback(sender) })
    }
}
