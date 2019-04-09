//
//  SttStorage.swift
//  STT
//
//  Created by Piter Standret on 1/22/19.
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
import KeychainSwift
import RxSwift

open class SttStorage<T: Codable>: SttStorageType {
    
    public typealias TEntity = T
    
    private let type: SttStoringType
    private let key: String
    
    private var keychain: KeychainSwift! = nil
    private var userDefault: UserDefaults! = nil
    
    public init (type: SttStoringType, key: String) {
        self.type = type
        self.key = key
        
        switch type {
        case .security:
            self.keychain = KeychainSwift()
        case .userAccount:
            self.userDefault = UserDefaults.standard
        }
    }
    
    open func get() -> T {
        switch type {
        case .security:
            return keychain.getData(key)!.getObject(of: TEntity.self)!
        case .userAccount:
            return userDefault.data(forKey: key)!.getObject(of: TEntity.self)!
        }
    }
    
    @discardableResult
    open func put(item: T) -> Bool {
        switch type {
        case .security:
            return keychain.set(item.getData()!, forKey: key)
        case .userAccount:
            userDefault.set(item.getData()!, forKey: key)
            return true
        }
    }
    
    @discardableResult
    open func drop() -> Bool {
        switch type {
        case .security:
            return keychain.delete(key)
        case .userAccount:
            userDefault.removeObject(forKey: key)
            return true
        }
    }
    
    open func isExists() -> Bool {
        switch type {
        case .security:
            return keychain.getData(key) != nil
        case .userAccount:
            return userDefault.data(forKey: key) != nil
        }
    }
    
    open func onUpdate() -> Observable<T> {
        notImplementException()
    }
}
