//
//  HttpManagerExtensions.swift
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

internal struct ServerErrorWrapper: ServerErrorType {
    var description: String
}

public extension ObservableType where Element == (HTTPURLResponse, Data) {
    
    ///
    /// Get particular result on 2xx codes
    ///
    func getResult<TResult: Decodable>() -> Observable<TResult> {
        return self.getResult(ofType: TResult.self)
    }
    
    ///
    /// Get particular result on 2xx codes and particular error for 4xx
    ///
    func getResult<TResult: Decodable, TError: ServerErrorType>(ofErrorType _: TError.Type) -> Observable<TResult> {
        return self.getResult(ofType: TResult.self, errorType: TError.self)
    }
    
    ///
    /// Get particular result on 2xx codes
    ///
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
                        SttLog.shared.error(message: "\(error)", key: "JSONCONVERT")
                        observer.onError(SttError.jsonConvert("\(error)"))
                    }
                case 400 ... 499:
                    let object = ServerErrorWrapper(description: String(data: data, encoding: String.Encoding.utf8) ?? "")
                    observer.onError(SttError.apiError(.badRequest(object)))
                case 500:
                    observer.onError(SttError.apiError(.internalServerError(String(data: data, encoding: String.Encoding.utf8) ?? "UNKNOWN")))
                default:
                    observer.onError(SttError.apiError(.unkown(urlResponse.statusCode, String(data: data, encoding: String.Encoding.utf8))))
                }
            }, onError: { (error) in
                if let er = error as? SttError {
                    observer.onError(er)
                }
                else {
                    let error = error as NSError
                    if error.code == -1009 { // TODO: fix
                        observer.onError(SttError.connectionError(.noInternetConnection))
                    }
                    else {
                        observer.onError(SttError.connectionError(.timeout))
                    }
                }
            }, onCompleted: observer.onCompleted)
        })
    }
    
    ///
    /// Get particular result on 2xx codes and particular error for 4xx
    ///
    func getResult<TResult: Decodable, TError: ServerErrorType>(
        ofType _: TResult.Type,
        errorType _: TError.Type
        ) -> Observable<TResult> {
        
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
                        SttLog.shared.error(message: "\(error)", key: "JSONCONVERT")
                        observer.onError(SttError.jsonConvert("\(error)"))
                    }
                case 400 ... 499:
                    if let object = try? JSONDecoder().decode(TError.self, from: data) {
                        observer.onError(SttError.apiError(.badRequest(object)))
                    }
                    else {
                        let object = ServerErrorWrapper(description: String(data: data, encoding: String.Encoding.utf8) ?? "")
                        observer.onError(SttError.apiError(.badRequest(object)))
                    }
                case 500:
                    observer.onError(SttError.apiError(.internalServerError(String(data: data, encoding: String.Encoding.utf8) ?? "UNKNOWN")))
                default:
                    observer.onError(SttError.apiError(.unkown(urlResponse.statusCode, String(data: data, encoding: String.Encoding.utf8))))
                }
            }, onError: { (error) in
                if let er = error as? SttError {
                    observer.onError(er)
                }
                else {
                    let error = error as NSError
                    if error.code == -1009 { // TODO: fix
                        observer.onError(SttError.connectionError(.noInternetConnection))
                    }
                    else {
                        observer.onError(SttError.connectionError(.timeout))
                    }
                }
            }, onCompleted: observer.onCompleted)
        })
    }
    
    ///
    /// Get void result. Ignore body fully
    ///
    func getResult() -> Observable<Void> {
        return Observable<Void>.create({ (observer) -> Disposable in
            self.subscribe(onNext: { (urlResponse, data) in
                switch urlResponse.statusCode {
                case 200 ... 299:
                    observer.onNext(())
                    observer.onCompleted()
                case 400 ... 499:
                    let object = ServerErrorWrapper(description: String(data: data, encoding: String.Encoding.utf8) ?? "")
                    observer.onError(SttError.apiError(.badRequest(object)))
                case 500:
                    observer.onError(SttError.apiError(.internalServerError(String(data: data, encoding: String.Encoding.utf8) ?? "UNKNOWN")))
                default:
                    observer.onError(SttError.apiError(.unkown(urlResponse.statusCode, String(data: data, encoding: String.Encoding.utf8))))
                }
            }, onError: { (error) in
                if let er = error as? SttError {
                    observer.onError(er)
                }
                else {
                    let error = error as NSError
                    if error.code == -1009 { // TODO: fix
                        observer.onError(SttError.connectionError(.noInternetConnection))
                    }
                    else {
                        observer.onError(SttError.connectionError(.timeout))
                    }
                }
            }, onCompleted: observer.onCompleted)
        })
    }
}
