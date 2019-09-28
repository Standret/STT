//
//  StringExtensions.swift
//  YURT
//
//  Created by Standret on 03.07.18.
//  Copyright © 2018 com.yurt.YURT. All rights reserved.
//

import Foundation

public extension String {
    
    ///
    /// Check if character is alphabetic
    ///
    func isAlpha() -> Bool {
        if let character = self.unicodeScalars.first {
            return CharacterSet.letters.contains(character)
        }
        return false
    }
    
    ///
    /// Check string for nil or empty
    ///
    static func isEmpty(_ string: String?) -> Bool {
        return (string ?? "").isEmpty
    }
    
    ///
    /// Check string for nil or whitespaces
    ///
    static func isWhiteSpace(_ string: String?) -> Bool {
        return (string ?? "").trimmingCharacters(in: .whitespaces).isEmpty
    }
}

public extension Bool {
    
    var string: String {
        return self ? "true" : "false"
    }
}

// MARK: - obsoleted block

@available(swift, obsoleted: 5.0, renamed: "String")
public class SttString {
    
    @available(swift, obsoleted: 5.0, renamed: "isEmpty(_:)")
    public class func isEmpty(string: String?) -> Bool {
        return (string ?? "").isEmpty
    }
    
    @available(swift, obsoleted: 5.0, renamed: "isWhiteSpace(_:)")
    public class func isWhiteSpace(string: String?) -> Bool {
        return (string ?? "").trimmingCharacters(in: .whitespaces).isEmpty
    }
}
