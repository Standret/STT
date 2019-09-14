//
//  SttHanlderSearchBar.swift
//  STT
//
//  Created by Piter Standret on 1/13/19.
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

public enum SttActionSearchBar {
    case cancelClicked
    case shouldBeginEditing
    case editing
    case searchClick
}

public class SttHanlderSearchBar: NSObject, UISearchBarDelegate {
    
    // private property
    private var handlers = [SttActionSearchBar: [SttDelegatedCall<UISearchBar>]]()
    private var shouldHandlers = [SttActionSearchBar: [(UISearchBar) -> Bool]]()

    public var maxCharacter: Int = Int.max
    
    // method for add target
    
    public func addTarget<T: AnyObject>(type: SttActionSearchBar, delegate: T, handler: @escaping (T, UISearchBar) -> Void) {
        
        handlers[type] = handlers[type] ?? [SttDelegatedCall<UISearchBar>]()
        handlers[type]?.append(SttDelegatedCall(to: delegate, with: handler))
    }
    
    public func addShouldReturnTarget<T: SttViewable>(type: SttActionSearchBar, delegate: T, handler: @escaping (T, UISearchBar) -> Bool) {
        
        if type != .shouldBeginEditing { fatalError("Incorrect type")}
        
        shouldHandlers[type] = shouldHandlers[type] ?? [(UISearchBar) -> Bool]()
        shouldHandlers[type]?.append({ [weak delegate] sb in
            
            if let _delegate = delegate {
                return handler(_delegate, sb)
            }
            
            return true
        })

    }
    // MARK: implementation of protocol UISearchBarDelegate
    
    open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        handlers[.cancelClicked]?.forEach({ $0.callback(searchBar) })
    }
    
    open func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        handlers[.shouldBeginEditing]?.forEach({ $0.callback(searchBar) })
        
        return shouldHandlers[.shouldBeginEditing]?.map({ $0(searchBar) }).last ?? true
    }
    
    open func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        handlers[.editing]?.forEach({ $0.callback(searchBar) })
    }
    
    open func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        handlers[.searchClick]?.forEach({ $0.callback(searchBar) })
    }
}
