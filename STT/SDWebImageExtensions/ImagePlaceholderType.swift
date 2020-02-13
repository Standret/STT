//
//  ImagePlaceholderType.swift
//  STT
//
//  Created by Peter Standret on 9/28/19.
//  Copyright © 2019 standret. All rights reserved.
//

import Foundation

public enum ImagePlaceholderType: Equatable {
    
    case none
    case avatar
    case usual
    case custom(String)
    
    var name: String? {
        var imageName: String?
        
        switch self {
        case .avatar:
            imageName = "no_pic"
        case .usual:
            imageName = "placeholder"
        case .custom(let name):
            imageName = name
        default: break
        }
        
        return imageName
    }
}
