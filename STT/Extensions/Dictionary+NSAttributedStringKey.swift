//
//  DictionaryExtensions+NSAttributedStringKey.swift
//  STT
//
//  Created by Peter Standret on 6/4/19.
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
import UIKit

extension Dictionary where Key == NSAttributedString.Key, Value == Any {

    var font: UIFont? { return self[.font] as? UIFont }
    var paragrapStyle: NSParagraphStyle? { return self[.paragraphStyle] as? NSParagraphStyle }
    
    var ligature: Int? { return self[.ligature] as? Int }
    var kern: Int? { return self[.kern] as? Int }
    var strikethroughStyle: Int? { return self[.strikethroughStyle] as? Int }
    var underlineStyle: Int? { return self[.underlineStyle] as? Int }
    var strokeWidth: Int? { return self[.strokeWidth] as? Int }

    var shadow: NSShadow? { return self[.shadow] as? NSShadow }
    var textEffect: String? { return self[.textEffect] as? String }
    var attachment: NSTextAttachment? { return self[.attachment] as? NSTextAttachment }
    var link: URL? { return self[.link] as? URL }
    
    var baselineOffset: Int? { return self[.baselineOffset] as? Int }
    var expansion: Int? { return self[.expansion] as? Int }
    var writingDirection: [Int]? { return self[.writingDirection] as? [Int] }
    var verticalGlyphForm: Int? { return self[.verticalGlyphForm] as? Int }

    var foregroundColor: UIColor? { return self[.foregroundColor] as? UIColor }
    var backgroundColor: UIColor? { return self[.backgroundColor] as? UIColor }
    var strokeColor: UIColor? { return self[.strokeColor] as? UIColor }
    var underlineColor: UIColor? { return self[.underlineColor] as? UIColor }
    var strikethroughColor: UIColor? { return self[.strikethroughColor] as? UIColor }

    // MARK: - obsoleted block
    
    @available(swift, obsoleted: 5.0, renamed: "foregroundColor")
    var color: UIColor? { return self[.foregroundColor] as? UIColor }
}
