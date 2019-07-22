//
//  HttpService.swift
//  STT
//
//  Created by Standret on 5/13/18.
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
import RxAlamofire
import RxSwift

public class SttHttpService: SttHttpServiceType {
    
    private let url: String!
    private let connectivity = SttConectivity()
    private let tokenGetter: (() -> Observable<String>)?
    
    private let timeout: DispatchTimeInterval
    
    public init(url: String, timeout: DispatchTimeInterval,
                tokenGetter: (() -> Observable<String>)? = nil) {
        
        self.url = url
        self.timeout = timeout
        self.tokenGetter = tokenGetter
    }
    
    public func get(controller: ApiControllerType,
                    data: [String: Any],
                    headers: [String:String],
                    insertToken: Bool) -> Observable<(HTTPURLResponse, Data)> {
        
        return modifyHeaders(insertToken: insertToken, headers: headers)
            .flatMap({ headers -> Observable<(HTTPURLResponse, Data)> in
                return  requestData(
                    .get,
                    "\(self.url!)\(controller.route)",
                    parameters: data,
                    encoding: URLEncoding.default,
                    headers: headers)
            }).timeout(timeout, scheduler: MainScheduler.instance)
    }
    
    public func post(controller: ApiControllerType,
                     data: [String: Any],
                     headers: [String:String],
                     insertToken: Bool,
                     encoding: ParameterEncoding) -> Observable<(HTTPURLResponse, Data)> {
        
        return modifyHeaders(insertToken: insertToken, headers: headers)
            .flatMap({ headers -> Observable<(HTTPURLResponse, Data)> in
                return requestData(
                    .post,
                    "\(self.url!)\(controller.route)",
                    parameters: data,
                    encoding: encoding,
                    headers: headers
                )
            })
            .timeout(timeout, scheduler: MainScheduler.instance)
    }
    
    public func delete(controller: ApiControllerType,
                       data: [String: Any],
                       headers: [String: String],
                       insertToken: Bool,
                       isFormUrlEncoding: Bool) -> Observable<(HTTPURLResponse, Data)> {
        
        return modifyHeaders(insertToken: insertToken, headers: headers)
            .flatMap({ headers -> Observable<(HTTPURLResponse, Data)> in
                return requestData(
                    .delete,
                    "\(self.url!)\(controller.route)",
                    parameters: data,
                    encoding: isFormUrlEncoding ? URLEncoding.httpBody : JSONEncoding.default,
                    headers: headers)
            })
            .timeout(timeout, scheduler: MainScheduler.instance)
    }
    
    public func put(controller: ApiControllerType,
                    data: [String: Any],
                    headers: [String: String],
                    insertToken: Bool,
                    isFormUrlEncoding: Bool) -> Observable<(HTTPURLResponse, Data)> {
        
        return modifyHeaders(insertToken: insertToken, headers: headers)
            .flatMap({ headers -> Observable<(HTTPURLResponse, Data)> in
                return requestData(
                    .put,
                    "\(self.url!)\(controller.route)",
                    parameters: data,
                    encoding: isFormUrlEncoding ? URLEncoding.httpBody : JSONEncoding.default,
                    headers: headers)
            })
            .timeout(timeout, scheduler: MainScheduler.instance)
    }
    
    public func upload(controller: ApiControllerType,
                       object: UploadedObject?,
                       parameters: [String: String],
                       headers: [String: String],
                       insertToken: Bool,
                       method: HTTPMethod,
                       progresHandler: ((Float) -> Void)?) -> Observable<(HTTPURLResponse, Data)> {
        
        let url = "\(self.url!)\(controller.route)"
        
        return modifyHeaders(insertToken: insertToken, headers: headers)
            .flatMap({ headers -> Observable<(HTTPURLResponse, Data)> in
                return Observable<(HTTPURLResponse, Data)>.create { (observer) -> Disposable in
                    
                    SttNetworking.sharedInstance.backgroundSessionManager
                        .upload(
                            multipartFormData: { (multipart) in
                                parameters.forEach({ multipart.append($0.value.data(using: .utf8)!, withName: $0.key) })
                                if let object = object {
                                    multipart .append(object.data, withName: object.name, fileName: object.fileName, mimeType: object.mimeType)
                                }
                        }, to: url, method: method, headers: headers) { (encodingResult) in
                            
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.uploadProgress(closure: { (progress) in
                                    if let handler = progresHandler {
                                        handler(Float(progress.fractionCompleted))
                                    }
                                })
                                
                                upload.responseData(completionHandler: { (fullData) in
                                    if upload.response != nil && fullData.data != nil {
                                        observer.onNext((upload.response!, fullData.data!))
                                        observer.onCompleted()
                                    }
                                    else {
                                        observer.onError(SttBaseError.connectionError(SttConnectionError.responseIsNil))
                                    }
                                })
                            case .failure(let encodingError):
                                observer.onError(SttBaseError.unkown("\(encodingError)"))
                            }
                    }
                    
                    return Disposables.create()
                }
            }).timeout(timeout, scheduler: MainScheduler.instance)
    }
    
    private func modifyHeaders(insertToken: Bool, headers: [String: String]) -> Observable<[String: String]> {
        
        if insertToken {
            return self.tokenGetter!()
                .map({ token in
                    var _headers = headers
                    _headers["Authorization"] = token
                    return _headers
                })
        }
        
        return Observable.just(headers)
    }
}
