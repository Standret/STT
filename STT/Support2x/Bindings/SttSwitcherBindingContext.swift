//
//  SttSwitcherBindingContext.swift
//  STT
//
//  Created by Peter Standret on 6/4/19.
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

public class SttSwitcherBindingContext<TViewController: AnyObject>: SttGenericTwoWayBindingContext<TViewController, Bool> {
    
    private var lazyWriterApply: ((Bool) -> Void)!
    
    weak private var target: Dynamic<Bool>!
    unowned private var switcher: UISwitch
    
    internal init (viewController: TViewController, switcher: UISwitch) {
        
        self.switcher = switcher
        
        super.init(viewController: viewController)
        super.withMode(.twoWayBind)
    }
    
    @discardableResult
    override public func to<TValue>(_ value: Dynamic<TValue>) -> SttGenericBindingContext<TViewController, Bool> {
        lazyWriterApply = { value.value = $0 as! TValue }
        return super.to(value)
    }
    
    override public func to(_ command: SttCommandType) -> SttGenericBindingContext<TViewController, Bool> {
        lazyWriterApply = { command.execute(parametr: $0) }
        return super.to(command)
    }
    
    // MARK: - applier
    
    override public func bindWriting() {
        switcher.addTarget(self, action: #selector(onValueChanged(_:)), for: .valueChanged)
    }
    
    override public func bindForProperty(_ value: Bool) {
        self.switcher.isOn = value
    }
    
    @objc
    private func onValueChanged(_ switcher: UISwitch) {
        lazyWriterApply(super.convertBackValue(switcher.isOn))
    }
}
