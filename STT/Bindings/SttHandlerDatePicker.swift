//
//  SttHandlerDatePicker.swift
//  STT
//
//  Created by Peter Standret on 3/18/19.
//  Copyright © 2019 standret. All rights reserved.
//

import Foundation
import UIKit

public enum SttActionDatePicker {
    case valueChanged
}

public final class SttHandlerDatePicker {
    
    private var handlers = [SttActionDatePicker: [SttDelegatedCall<UIDatePicker>]]()
    
    public init(_ button: UIDatePicker) {
        button.addTarget(self, action: #selector(onValueChanged(_:)), for: .valueChanged)
    }
    
    public func addTarget<T: AnyObject>(type: SttActionDatePicker, delegate: T, handler: @escaping (T, UIDatePicker) -> Void) {
        
        handlers[type] = handlers[type] ?? [SttDelegatedCall<UIDatePicker>]()
        handlers[type]?.append(SttDelegatedCall<UIDatePicker>(to: delegate, with: handler))
    }
    
    @objc
    private func onValueChanged(_ sender: UIDatePicker) {
        handlers[.valueChanged]?.forEach({ $0.callback(sender) })
    }
}
