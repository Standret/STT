//
//  GlobalObserver.swift
//  STT
//
//  Created by Peter Standret on 9/14/19.
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

///
/// The enum describe different application status
//
public enum ApplicationStatus {
    case willBecomeInActive
    case didEnterBackgound
    case willEnterForeground
    case didBecomeActive
    case willTerminate
}

///
/// Provide a delegate to handle different system events
///
public protocol GlobalObserverDelegate {
    
    ///
    /// Methods to react on application status change.
    /// - Important: This method does not work without calling to
    /// GlobalObserver.applicationStatusChanged(with:)
    ///
    func applicationStatusChanged(with status: ApplicationStatus)
}

///
/// Provide functionality to observe global events
///
public final class GlobalObserver {
    
    public static var shared = GlobalObserver()
    
    public var isEnabled = true
    
    private var delegates = MulticastDelegate<GlobalObserverDelegate>()
    
    private init() { }
    
    public func addObserver(delegate: GlobalObserverDelegate) {
        delegates += delegate
    }
    
    public func removeObserver(delegate: GlobalObserverDelegate) {
        delegates -= delegate
    }
    
    public func applicationStatusChanged(with status: ApplicationStatus) {
        delegates.invokeDelegates({ $0.applicationStatusChanged(with: status) })
    }
}
