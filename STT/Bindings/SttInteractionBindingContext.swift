//
//  SttInteractionBindingContext.swift
//  STT
//
//  Created by Peter Standret on 3/19/19.
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

import Foundation
import RxSwift
import UIKit

public enum SttInteractionType {
    case tap(Int)
    case longTap(TimeInterval)
}

public struct SttBindingInteractionData {
    let type: SttInteractionType
    let target: UIView
}

public extension UIView {
    
    func tap(taps: Int = 1) -> SttBindingInteractionData {
        return SttBindingInteractionData(type: .tap(taps), target: self)
    }
    
    func longTap(duration: TimeInterval) -> SttBindingInteractionData {
        return SttBindingInteractionData(type: .longTap(duration), target: self)
    }
    
}

public class SttInteractionBindingContext<TViewController: AnyObject>: SttGenericBindingContext<TViewController, String?> {
    
    internal init (viewController: TViewController, data: SttBindingInteractionData) {
        
        super.init(vc: viewController)
        
        data.target.isUserInteractionEnabled = true
        switch data.type {
        case .tap(let taps):
            let gesture = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
            gesture.numberOfTouchesRequired = taps
            data.target.addGestureRecognizer(gesture)
        case .longTap(let duration):
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongTap(_:)))
            gesture.minimumPressDuration = duration
            data.target.addGestureRecognizer(gesture)
        }
    }
    
    @objc
    private func onTap(_ sender: UITapGestureRecognizer) {
        self.command.execute(parametr: parametr)
    }
    
    @objc
    private func onLongTap(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            self.command.execute(parametr: parametr)
        }
    }
}
