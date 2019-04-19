//
//  SttResultConverter.swift
//  SttDictionary
//
//  Created by Standret on 22.06.18.
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

public extension ObservableType where E == (HTTPURLResponse, Data) {
    
    func getCookie(action: @escaping (String?) -> Void) -> Observable<(HTTPURLResponse, Data)> {
        return self.map({ (result) -> (HTTPURLResponse, Data) in
            let header = result.0.allHeaderFields as NSDictionary
            let tockenval = header.value(forKey: "authenticate") as? String
            action(tockenval)
            
            return result
            })
    }
    
    func getResult<TResult: Decodable>() -> Observable<TResult> {
        return self.getResult(ofType: TResult.self)
    }
    
    func getResult<TResult: Decodable>(ofType _: TResult.Type) -> Observable<TResult> {
        return Observable<TResult>.create({ (observer) -> Disposable in
            self.subscribe(onNext: { (urlResponse, data) in
                switch urlResponse.statusCode {
                case 200 ... 299:
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .customISO8601
                        let jsonObject = try decoder.decode(TResult.self, from: data)
                        observer.onNext(jsonObject)
                    }
                    catch {
                        print(error)
                        observer.onError(SttBaseError.jsonConvert("\(error)"))
                    }
                case 400:
                    let object = (try? JSONDecoder().decode(ServerError.self, from: data))
                            ?? ServerError(code: 400, description: (String(data: data, encoding: String.Encoding.utf8) ?? ""))
                    observer.onError(SttBaseError.apiError(SttApiError.badRequest(object)))
                case 500:
                    observer.onError(SttBaseError.apiError(SttApiError.internalServerError(String(data: data, encoding: String.Encoding.utf8) ?? "nil")))
                default:
                    observer.onError(SttBaseError.apiError(SttApiError.otherApiError(urlResponse.statusCode)))
                }
            }, onError: { (error) in
                if let er = error as? SttBaseError {
                    observer.onError(er)
                }
                else {
                    let error = error as NSError
                    if error.code == -1009 { // TODO: fix
                        observer.onError(SttBaseError.connectionError(SttConnectionError.noInternetConnection))
                    }
                    else {
                        observer.onError(SttBaseError.connectionError(SttConnectionError.timeout))
                    }
                }
            }, onCompleted: observer.onCompleted)
        })
    }
    
    func getResult() -> Observable<Void> {
        return Observable<Void>.create({ (observer) -> Disposable in
            self.subscribe(onNext: { (urlResponse, data) in
                switch urlResponse.statusCode {
                case 200 ... 299:
                    observer.onNext(())
                    observer.onCompleted()
                case 400:
                    let object = (try? JSONDecoder().decode(ServerError.self, from: data))
                        ?? ServerError(code: 400, description: (String(data: data, encoding: String.Encoding.utf8) ?? ""))
                    observer.onError(SttBaseError.apiError(SttApiError.badRequest(object)))
                case 500:
                    observer.onError(SttBaseError.apiError(SttApiError.internalServerError(String(data: data, encoding: String.Encoding.utf8) ?? "nil")))
                default:
                    observer.onError(SttBaseError.apiError(SttApiError.otherApiError(urlResponse.statusCode)))
                }
            }, onError: { (error) in
                if let er = error as? SttBaseError {
                    observer.onError(er)
                }
                else {
                    observer.onError(SttBaseError.unkown("\(error)"))
                }
            }, onCompleted: nil, onDisposed: nil)
        })
    }
}
