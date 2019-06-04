//
//  SttDictionaryExtensions.swift
//  STT
//
//  Created by Peter Standret on 6/4/19.
//  Copyright © 2019 standret. All rights reserved.
//

import Foundation
import UIKit

extension Dictionary where Key == NSAttributedString.Key, Value == Any {
    
    var color: UIColor? { return self[.foregroundColor] as? UIColor }
    var font: UIFont? { return self[.font] as? UIFont }
}
