//
//  ConnectionError.swift
//  STT
//
//  Created by Peter Standret on 9/21/19.
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

public enum ConnectionError: Error, LocalizedError {
    
    case timeout
    case noInternetConnection
    case responseIsNil
    case other(String)
    
    // TODO: BELOW CODE AS BACKWARD COMPATABILITY WITH 3.x will be completely removed in 4.x
    
    public var localizedDescription: String {
        switch self {
        case .noInternetConnection: return "No internet connection"
        case .timeout: return "Couldn't connect to server"
        case .responseIsNil: return "Request timeout"
        case .other(let title): return title
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .noInternetConnection: return "Check your settings or repeat later"
        case .timeout: return "There was a problem of loading data. Check your Internet connection and try again."
        case .responseIsNil: return "Please try again"
        case .other: return nil
        }
    }
}
