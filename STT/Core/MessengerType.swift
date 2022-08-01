//
//  MessengerType.swift
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

public enum MessageLevelType {
    case message
    case trace
    case warning
    case error
    case fatalError
}

public struct LogMessage: Equatable {
    
    public let type: MessageLevelType
    public let title: String
    public let description: String?
    public let debugDescription: String?
    
    public init(
        type: MessageLevelType,
        title: String,
        description: String?,
        debugDescription: String?
        ) {
        
        self.type = type
        self.title = title
        self.description = description
        self.debugDescription = debugDescription
    }
}

public protocol MessengerType: class {
    var messages: Event<LogMessage> { get }
    func publish(message: LogMessage)
}

public extension MessengerType {
    func error(title: String, description: String? = nil, debugDescription: String? = nil) {
        self.publish(message: .init(type: .message, title: title, description: description, debugDescription: debugDescription))
    }
    func messege(title: String, description: String? = nil) {
        self.publish(message: .init(type: .message, title: title, description: description, debugDescription: nil))
    }
}

open class Messenger: MessengerType {
    
    private var messagesSubject = EventPublisher<LogMessage>()
    open var messages: Event<LogMessage> { return messagesSubject }
    
    public init() {
        
    }
    
    public func publish(message: LogMessage) {
        messagesSubject.invoke(message)
    }
}
