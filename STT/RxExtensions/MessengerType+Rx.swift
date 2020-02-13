//
//  ErrorManagerType+Rx.swift
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
import RxSwift

public extension MessengerType {
    
    func useError<T>(
        observable: Observable<T>,
        ignoreBadRequest: Bool = false,
        customMessage: String? = nil
    ) -> Observable<T> {
        
        return observable.do(onError: { (error) in
            if let error = error as? SttError {
                var flag = true
                
                if ignoreBadRequest {
                    switch error {
                    case .apiError(let api):
                        switch api {
                        case .badRequest(_):
                            flag = false
                        case .unknown(let code, _):
                            flag = code != 401
                        default: break
                        }
                    default: break
                    }
                    if flag {
                        self.publish(message: LogMessage(
                            type: .error,
                            title: "Something went wrong.",
                            description: "Try again later.",
                            debugDescription: "\(error)"
                            )
                        )
                    }
                    else if let messageError = customMessage {
                        self.publish(message: LogMessage(
                            type: .error,
                            title: messageError,
                            description: nil,
                            debugDescription: "\(error)"
                            )
                        )
                    }
                }
                else {
                    self.publish(message: LogMessage(
                        type: .error,
                        title: error.message.title,
                        description: error.message.description,
                        debugDescription: "\(error)"
                        )
                    )
                }
            }
            else {
                self.publish(message: LogMessage(
                    type: .error,
                    title: "Something went wrong",
                    description: "Try again later.",
                    debugDescription: "\(error)"
                    )
                )
            }
        })
    }
}

public extension Observable {
    
    func useError(
        service: MessengerType,
        ignoreBadRequest: Bool = false,
        customMessage: String? = nil
    ) -> Observable<Element> {
        
        return service.useError(
            observable: self,
            ignoreBadRequest: ignoreBadRequest,
            customMessage: customMessage
        )
    }
}
