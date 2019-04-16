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
    
    private let timeout: Double
    
    public init(url: String, timeout: Double, tokenGetter: (() -> Observable<String>)? = nil) {
        self.url = url
        self.timeout = timeout
        self.tokenGetter = tokenGetter
    }
    
    public func get(controller: ApiControllerType, data: [String: Any], headers: [String:String], insertToken: Bool) -> Observable<(HTTPURLResponse, Data)> {
        
        return modifyHeaders(insertToken: insertToken, headers: headers)
            .flatMap({ headers -> Observable<(HTTPURLResponse, Data)> in
                return  requestData(.get,
                                   "\(self.url!)\(controller.route)",
                                   parameters: data,
                                   encoding: URLEncoding.default,
                                   headers: headers)
            })
            .timeout(timeout, scheduler: MainScheduler.instance)
    }
    
    /// if key parametr is empty string and parametr is simple type, its will be insert in raw body
    public func post(controller: ApiControllerType, data: [String: Any], headers: [String:String], insertToken: Bool) -> Observable<(HTTPURLResponse, Data)> {
        
        return modifyHeaders(insertToken: insertToken, headers: headers)
            .flatMap({ headers -> Observable<(HTTPURLResponse, Data)> in
                return requestData(.post,
                                   "\(self.url!)\(controller.route)",
                                   parameters: data,
                                   encoding: URLEncoding.httpBody,
                                   headers: headers)
                })
            .timeout(timeout, scheduler: MainScheduler.instance)
    }
    
    public func post(controller: ApiControllerType, object: Encodable?, headers: [String:String], insertToken: Bool, isFormUrlEncoding: Bool) -> Observable<(HTTPURLResponse, Data)> {
        
        return modifyHeaders(insertToken: insertToken,
                             headers: self.modifyHeaders(isFormUrlEncoding: isFormUrlEncoding, to: headers))
            .flatMap({ headers -> Observable<(HTTPURLResponse, Data)> in
                
                var request = URLRequest(url: URL(string: "\(self.url!)\(controller.route)")!)
                request.httpMethod = HTTPMethod.post.rawValue
    
                if isFormUrlEncoding {
                    request.httpBody = object?.getData()
                }
                else {
                    request.httpBody = (object?.getJsonString().data(using: .utf8, allowLossyConversion: false))
                }
    
                for lhitem in headers {
                    request.setValue(lhitem.value, forHTTPHeaderField: lhitem.key)
                }
                
                return requestData(request)
            })
            .timeout(timeout, scheduler: MainScheduler.instance)
    }
    
    public func delete(controller: ApiControllerType, data: [String: Any], headers: [String: String], insertToken: Bool) -> Observable<(HTTPURLResponse, Data)> {
        
        return modifyHeaders(insertToken: insertToken, headers: headers)
            .flatMap({ headers -> Observable<(HTTPURLResponse, Data)> in
                return requestData(.delete,
                                   "\(self.url!)\(controller.route)",
                    parameters: data,
                    encoding: URLEncoding.httpBody,
                    headers: headers)
            })
            .timeout(timeout, scheduler: MainScheduler.instance)
    }
    
    public func upload(controller: ApiControllerType, data: Data, parameter: [String:String], progresHandler: ((Float) -> Void)?) -> Observable<(HTTPURLResponse, Data)> {
        notImplementException()

    }
    
    private func modifyHeaders(isFormUrlEncoding: Bool, to headers: [String: String]) -> [String: String] {
        
        var _headers = headers
        
        if isFormUrlEncoding {
            _headers["Content-Type"] = "application/x-www-form-urlencoded"
        }
        else {
            _headers["Content-Type"] = "application/json"
        }
        
        return _headers
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
