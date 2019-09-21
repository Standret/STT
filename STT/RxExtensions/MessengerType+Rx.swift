//
//  ErrorManagerType+Rx.swift
//  STT
//
//  Created by Peter Standret on 9/21/19.
//  Copyright © 2019 standret. All rights reserved.
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
                }
                if flag {
                    self.publish(message: LogMessage(
                        type: .error,
                        title: "Something wen wrong.",
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
