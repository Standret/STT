//
//  ApiError.swift
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

public enum ApiError: Error, LocalizedError {
    
    case badRequest(ServerErrorType)
    case internalServerError(String)
    case unknown(Int, String?)
    
    // TODO: BELOW CODE AS BACKWARD COMPATABILITY WITH 3.x will be completely removed in 4.x
    
    // title
    public var errorDescription: String? {
        switch self {
        case .badRequest: return "Bad request"
        case .internalServerError: return "Internal Server Error"
        case .unknown(let code, _): return "Unkown API Error with code: \(code)"
        }
    }
    
    // description
    public var failureReason: String? {
        switch self {
        case .badRequest(let error): return error.description
        case .internalServerError(let message): return message
        case .unknown(_, let description): return description
        }
    }
}
