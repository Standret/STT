//
//  UIPanGestureRecognizer.swift
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

public enum GestureDirection: Int {
    case up
    case down
    case left
    case right
    case none
    
    var isX: Bool { return self == .left || self == .right }
    var isY: Bool { return !isX }
}

public extension UIPanGestureRecognizer {
    
    ///
    /// Return direction of draging on pan gesture
    ///
    func getDirection(in view: UIView) -> GestureDirection {
        let _velocity = velocity(in: view)
        let vertical = abs(_velocity.y) > abs(_velocity.x)
        switch (vertical, _velocity.x, _velocity.y) {
        case (true, _, let y) where y < 0: return .up
        case (true, _, let y) where y > 0: return .down
        case (false, let x, _) where x > 0: return .right
        case (false, let x, _) where x < 0: return .left
        default: return .none
        }
    }
}

// MARK: - obsoleted block

///
/// Return JSON String for given object
///

@available(swift, obsoleted: 5.0, renamed: "GestureDirection")
public enum SttDirection: Int {
    case up
    case down
    case left
    case right
    case none
    
    var isX: Bool { return self == .left || self == .right }
    var isY: Bool { return !isX }
}
