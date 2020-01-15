//
//  Image.swift
//  STT
//
//  Created by Peter Standret on 9/28/19.
//  Copyright © 2019 standret. All rights reserved.
//

import Foundation

public struct Image: Equatable {
    
    public let data: Data?
    public let url: String?
    public let shouldLoadPlaceholder: Bool
    
    public var isEmpty: Bool {
        return data == nil && (url ?? "").isEmpty
    }

    public init(data: Data? = nil,
         url: String? = nil,
         shouldLoadPlaceholder: Bool = true) {
        
        self.data = data
        self.url = url
        self.shouldLoadPlaceholder = shouldLoadPlaceholder
    }
}
