//
//  SttBaseError.swift
//  STT
//
//  Created by Peter Standret on 2/1/19.
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

public enum SttBaseError: Error, SttBaseErrorType {
    case realmError(SttRealmError)
    case apiError(SttApiError)
    case connectionError(SttConnectionError)
    case jsonConvert(String)
    case unkown(String)
    
    public func getMessage() -> (String, String) {
        var result: (String, String)!
        switch self {
        case .realmError(let concreate):
            let tempRes = concreate.getMessage()
            result = ("Realm: \(tempRes.0)", tempRes.1)
        case .apiError(let concreate):
            let tempRes = concreate.getMessage()
            result = (tempRes.1, "Api: \(tempRes.0) \(tempRes.1)")
        case .connectionError(let concreate):
            let tempRes = concreate.getMessage()
            result = ("\(tempRes.0)", tempRes.1)
        case .jsonConvert(let message):
            result = ("Json convert", message)
        case .unkown(let message):
            result = (message, "Description is out")
        }
        
        return result
    }
}
