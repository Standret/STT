//
//  ArrayExtensions.swift
//  STT
//
//  Created by Piter Standret on 6/3/18.
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

public extension Array {
    
    public func getElement(indexes: [Int]) -> Array<Element> {
        var arr = [Element]()
        for index in indexes {
            arr.append(self[index])
        }
        return arr
    }
    
    public mutating func getAndDelete(index: Int) -> Element {
        let elem = self[index]
        self.remove(at: index)
        return elem
    }
    
    public func insertAndReturn(element: Element, at index: Int) -> Array<Element> {
        var newSequence = self
        newSequence.insert(element, at: index)
        return newSequence
    }
}
