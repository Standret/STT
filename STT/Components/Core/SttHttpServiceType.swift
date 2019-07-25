//
//  SttHttpServiceType.swift
//  STT
//
//  Created by Piter Standret on 1/2/19.
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

public struct UploadedObject {
    let data: Data
    let name: String
    let fileName: String
    let mimeType: String
    
    public init(data: Data,
                name: String,
                fileName: String,
                mimeType: String) {
        
        self.data = data
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }
}

public protocol SttHttpServiceType {
    
    func get(controller: ApiControllerType, data: [String: Any], headers: [String:String], insertToken: Bool) -> Observable<(HTTPURLResponse, Data)>
    
    func post(controller: ApiControllerType, data: [String: Any], headers: [String:String], insertToken: Bool, encoding: ParameterEncoding) -> Observable<(HTTPURLResponse, Data)>
    
    func delete(controller: ApiControllerType, data: [String: Any], headers: [String: String], insertToken: Bool, isFormUrlEncoding: Bool) -> Observable<(HTTPURLResponse, Data)>
    
    func put(controller: ApiControllerType, data: [String: Any], headers: [String: String], insertToken: Bool, isFormUrlEncoding: Bool) -> Observable<(HTTPURLResponse, Data)>
    
    func upload(controller: ApiControllerType,
                object: UploadedObject?,
                parameters: [String: String],
                headers: [String: String],
                insertToken: Bool,
                method: HTTPMethod,
                progresHandler: ((Float) -> Void)?,
                sessionManager: SessionManager?) -> Observable<(HTTPURLResponse, Data)>
}
