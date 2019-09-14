//
//  SttButtonBindingSet.swift
//  STT
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
import RxSwift
import UIKit

// TODO: write this comment
/**
 A binding for button events (touchUpInside by default)
 and redirect this events to command
 */
public class SttButtonBindingSet: SttBindingContextType {

    unowned private let button: UIButton

    private let handler: SttHandlerButton
    private var command: SttCommandType!
    private var parametr: Any?
    
    private var disposeBag = DisposeBag()
    
    init (button: UIButton) {
        
        self.handler = SttHandlerButton(button)
        self.button = button
    }
    
    @discardableResult
    public func to(_ command: SttCommandType) -> SttButtonBindingSet {
        self.command = command
        
        return self
    }
    
    @discardableResult
    public func withCommandParametr(_ parametr: Any) -> SttButtonBindingSet {
        self.parametr = parametr
        
        return self
    }
    
    public func apply() {
        button.isEnabled = command.canExecute(parametr: parametr)
        command.observableCanNext
            .subscribe(onNext: { [unowned self] in self.button.isEnabled = $0 })
            .disposed(by: disposeBag)
        handler.addTarget(type: .touchUpInside, delegate: self, handler: { (d,_) in d.command.execute(parametr: d.parametr) })
    }
}

/**
 
 Custom operators
 Second way to write bindings
 
 For more information look at our documentation on github
 
 UPS :\ Something missing
 If you see this message just write me. Prter Standret
 
 */

@discardableResult
public func ->> (left: SttButtonBindingSet, right: SttCommandType) -> SttButtonBindingSet{
    return left.to(right)
}

@discardableResult
public func -< (left: SttButtonBindingSet, right: Any) -> SttButtonBindingSet {
    return left.withCommandParametr(right)
}
