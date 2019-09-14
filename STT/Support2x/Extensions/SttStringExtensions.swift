//
//  SttStringExtensions.swift
//  YURT
//
//  Created by Standret on 03.07.18.
//  Copyright © 2018 com.yurt.YURT. All rights reserved.
//

import Foundation
import Alamofire

extension String: ParameterEncoding {
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
    
    public func isAlpha() -> Bool {
        if let character = self.unicodeScalars.first {
            return CharacterSet.letters.contains(character)
        }
        return false
    }
}

public class SttString {
    public class func isEmpty(string: String?) -> Bool {
        return (string ?? "").isEmpty
    }
    
    public class func isWhiteSpace(string: String?) -> Bool {
        return (string ?? "").trimmingCharacters(in: .whitespaces).isEmpty
    }
}
