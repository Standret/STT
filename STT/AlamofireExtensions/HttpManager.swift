//
//  HttpManager.swift
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
import Alamofire
import RxSwift

public class HttpManager: HttpManagerType {
    
    private let timeout: DispatchTimeInterval
    private let uploadTimeout: DispatchTimeInterval
    
    private let requestSessionManager: Session?
    private let uploadSessionManager: Session?
    
    public init(
        timeout: DispatchTimeInterval,
        uploadTimeout: DispatchTimeInterval,
        requestSessionManager: Session? = nil,
        uploadSessionManager: Session? = nil
    ) {
        
        self.timeout = timeout
        self.uploadTimeout = uploadTimeout
        
        self.requestSessionManager = requestSessionManager
        self.uploadSessionManager = uploadSessionManager
    }
    
    public func request(
        _ method: HTTPMethod,
        controller: ApiControllerType,
        parameter: Parameters?,
        headers: HTTPHeaders?,
        encoding: ParameterEncoding,
        isAuthorized: Bool
    ) -> Observable<(HTTPURLResponse, Data)> {
        
        return Observable.create({ (observer) -> Disposable in
            
            let manager = self.requestSessionManager ?? Session.default
            var headers = headers ?? [:]
            if isAuthorized {
                headers["Authorization"] = ""
            }
            
            let dataRequest = manager.request(
                controller,
                method: method,
                parameters: parameter,
                encoding: encoding,
                headers: headers
            ).validate()
                .response(completionHandler: { (response) in
                    if let data = response.data, let response = response.response {
                        observer.onNext((response, data))
                        observer.onCompleted()
                    }
                    else {
                        observer.onError(ConnectionError.responseIsNil)
                    }
                })
            
            
            return Disposables.create {
                dataRequest.cancel()
            }
        }).timeout(timeout, scheduler: MainScheduler.instance)
    }
    
    public func upload(
        _ method: HTTPMethod,
        controller: ApiControllerType,
        object: UploadObject?,
        parameters: [String: String],
        headers: HTTPHeaders?,
        isAuthorized: Bool,
        progresHandler: ((Float) -> Void)?
    ) -> Observable<(HTTPURLResponse, Data)> {
        
        return Observable.create({ (observer) -> Disposable in
            
            let sessionManager = self.uploadSessionManager ?? Session.default
            var request: UploadRequest?
            
            var headers = headers ?? [:]
            if isAuthorized {
                headers["Authorization"] = ""
            }
            
            request = sessionManager.upload(multipartFormData: { (multipart) in
                
                parameters.forEach({
                    multipart.append(
                        $0.value.data(using: .utf8)!,
                        withName: $0.key
                    )
                })
                
                if let object = object {
                    multipart .append(
                        object.data,
                        withName: object.name,
                        fileName: object.fileName,
                        mimeType: object.mimeType
                    )
                }
            }, to: controller,
               method: method,
               headers: headers,
               interceptor: nil,
               fileManager: .default)
                .validate()
                .uploadProgress(closure: { progress in
                    if let handler = progresHandler {
                        handler(Float(progress.fractionCompleted))
                    }
                })
                .response(completionHandler: { (encodingResult) in
                    switch encodingResult.result {
                    case .success(let data):
                        
                        if encodingResult.response != nil && data != nil {
                            observer.onNext((encodingResult.response!, data!))
                            observer.onCompleted()
                        }
                        else {
                            observer.onError(SttError.connectionError(.responseIsNil))
                        }
                        
                    case .failure(let encodingError):
                        
                        observer.onError(SttError.unkown("\(encodingError)"))
                    }
                    
                })
            
            return Disposables.create {
                request?.cancel()
            }
        }).timeout(uploadTimeout, scheduler: MainScheduler.instance)
    }
}
