//
//  HttpManagerType.swift
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

public protocol HttpManagerType {
    
    func request(
        _ method: HTTPMethod,
        controller: ApiControllerType,
        parameter: Parameters?,
        headers: HTTPHeaders?,
        encoding: ParameterEncoding,
        isAuthorized: Bool
        ) -> Observable<(HTTPURLResponse, Data)>
    
    func upload(
        _ method: HTTPMethod,
        controller: ApiControllerType,
        object: UploadObject?,
        parameters: [String: String],
        headers: HTTPHeaders?,
        isAuthorized: Bool,
        progresHandler: ((Float) -> Void)?
        ) -> Observable<(HTTPURLResponse, Data)>
}

public extension HttpManagerType {
    
    // MARK: - request
    
    func request(
        _ method: HTTPMethod,
        controller: ApiControllerType,
        object: Encodable,
        headers: HTTPHeaders?,
        encoding: ParameterEncoding,
        isAuthorized: Bool
        ) -> Observable<(HTTPURLResponse, Data)> {
        
        return self.request(
            method,
            controller: controller,
            parameter: object.getDictionary(),
            headers: headers,
            encoding: encoding,
            isAuthorized: isAuthorized
        )
    }
    
    // MARK: - GET
    
    func get(
        controller: ApiControllerType,
        parameter: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        isAuthorized: Bool = false
        ) -> Observable<(HTTPURLResponse, Data)> {
        
        return self.request(
            .get,
            controller: controller,
            parameter: parameter,
            headers: headers,
            encoding: encoding,
            isAuthorized: isAuthorized
        )
    }
    
    func get(
        controller: ApiControllerType,
        object: Encodable,
        headers: HTTPHeaders? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        isAuthorized: Bool = false
        ) -> Observable<(HTTPURLResponse, Data)> {
        
        return self.request(
            .get,
            controller: controller,
            parameter: object.getDictionary(),
            headers: headers,
            encoding: encoding,
            isAuthorized: isAuthorized
        )
    }
    
    // MARK: - POST
    
    func post(
        controller: ApiControllerType,
        parameter: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        isAuthorized: Bool = false
        ) -> Observable<(HTTPURLResponse, Data)> {
        
        return self.request(
            .post,
            controller: controller,
            parameter: parameter,
            headers: headers,
            encoding: encoding,
            isAuthorized: isAuthorized
        )
    }
    
    func post(
        controller: ApiControllerType,
        object: Encodable,
        headers: HTTPHeaders? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        isAuthorized: Bool = false
        ) -> Observable<(HTTPURLResponse, Data)> {
        
        return self.request(
            .post,
            controller: controller,
            parameter: object.getDictionary(),
            headers: headers,
            encoding: encoding,
            isAuthorized: isAuthorized
        )
    }
    
    // MARK: - DELETE
    
    func delete(
        controller: ApiControllerType,
        parameter: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        isAuthorized: Bool = false
        ) -> Observable<(HTTPURLResponse, Data)> {
        
        return self.request(
            .delete,
            controller: controller,
            parameter: parameter,
            headers: headers,
            encoding: encoding,
            isAuthorized: isAuthorized
        )
    }
    
    func delete(
        controller: ApiControllerType,
        object: Encodable,
        headers: HTTPHeaders? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        isAuthorized: Bool = false
        ) -> Observable<(HTTPURLResponse, Data)> {
        
        return self.request(
            .delete,
            controller: controller,
            parameter: object.getDictionary(),
            headers: headers,
            encoding: encoding,
            isAuthorized: isAuthorized
        )
    }
    
    // MARK: - PUT
    
    func put(
        controller: ApiControllerType,
        parameter: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        isAuthorized: Bool = false
        ) -> Observable<(HTTPURLResponse, Data)> {
        
        return self.request(
            .put,
            controller: controller,
            parameter: parameter,
            headers: headers,
            encoding: encoding,
            isAuthorized: isAuthorized
        )
    }
    
    func put(
        controller: ApiControllerType,
        object: Encodable,
        headers: HTTPHeaders? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        isAuthorized: Bool = false
        ) -> Observable<(HTTPURLResponse, Data)> {
        
        return self.request(
            .put,
            controller: controller,
            parameter: object.getDictionary(),
            headers: headers,
            encoding: encoding,
            isAuthorized: isAuthorized
        )
    }
    
    // MARK: PATCH
    
    func patch(
        controller: ApiControllerType,
        parameter: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        isAuthorized: Bool = false
        ) -> Observable<(HTTPURLResponse, Data)> {
        
        return self.request(
            .patch,
            controller: controller,
            parameter: parameter,
            headers: headers,
            encoding: encoding,
            isAuthorized: isAuthorized
        )
    }
    
    func patch(
        controller: ApiControllerType,
        object: Encodable,
        headers: HTTPHeaders? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        isAuthorized: Bool = false
        ) -> Observable<(HTTPURLResponse, Data)> {
     
        return self.request(
            .put,
            controller: controller,
            parameter: object.getDictionary(),
            headers: headers,
            encoding: encoding,
            isAuthorized: isAuthorized
        )
    }
}
