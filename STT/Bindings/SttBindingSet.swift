//
//  SttBindingSet.swift
//  STT
//
//  Created by Peter Standret on 2/7/19.
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

/**
 An abstraction of binding context. Give a target object with method for target binding elements on view,
 provide in target clouser safe property to target view controller.
 When all elements were binded user have to call aplly to accept all bindings.
 
 ### Usage Example: ###
 ````
 var set = SttBindingSet(parent: self)
 
 // all binding here
 
 set.apply()
 
 ````
 */
public class SttBindingSet<TViewController: AnyObject> {
    
    private unowned var parent: TViewController
    
    private var sets = [SttBindingContextType]()
    
    public init (parent: TViewController) {
        self.parent = parent
    }
    
    public func bind(_ label: UILabel) -> SttLabelBindingContext<TViewController> {
        
        let set = SttLabelBindingContext(viewController: parent, label: label)
        
        set.forProperty { (_,value) in label.text = value }
        sets.append(set)
        
        return set
    }
    
    /**
     Use for text field (one way and two way bindings)
     
     - Important:
     property delegate in target textfield have to be empty or have type **SttHandlerTextField**
     otherwise this method throw fatalError()
     
     */
    public func bind(_ textField: UITextField) -> SttTextFieldBindingContext<TViewController> {

        var data: (SttHandlerTextField, UITextField)!
        
        if let handler = textField.delegate as? SttHandlerTextField {
            data = (handler, textField)
        }
        else if textField.delegate != nil {
            fatalError("Incorrect delegate in TextField. Expected type nil or SttHandlerTextField")
        }
        else {
            let handler = SttHandlerTextField()
            textField.delegate = handler

            data = (handler, textField)
        }
        
        let set = SttTextFieldBindingContext<TViewController>(viewController: parent, handler: data.0, textField: data.1)
        sets.append(set)
        
        return set
    }
    
    public func bind(_ button: UIButton) -> SttButtonBindingSet {
        
        let set = SttButtonBindingSet(button: button)
        sets.append(set)
        return set
    }
    
    /**
     Use for abstract binding.
     
     - REMARK:
     It is reccomend to use only if there are not any **specific** bindings.
     
     - PARAMETER context: Target type which you expect to assign in binding cloisure
     
     ### Usage Example: ###
     ````
     set.bind(TargetType.self)
     
     ````
    */
    public func bind<T>(_ context: T.Type) -> SttGenericBindingContext<TViewController, T> {
        
        let set = SttGenericBindingContext<TViewController, T>(vc: parent)
        sets.append(set)
        return set
    }
    
    /// apply all bindings setted in set
    public func apply() {
        sets.forEach({ $0.apply() })
    }
}
