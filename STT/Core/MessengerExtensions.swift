//
//  MessengerExtensions.swift
//  STT
//
//  Created by Peter Standret on 12.10.2019.
//  Copyright © 2019 standret. All rights reserved.
//

import Foundation

public extension MessengerType {
    
    func sendMessage(title: String, description: String? = nil) {
        self.publish(message:
            LogMessage(
                type: .message,
                title: title,
                description: description,
                debugDescription: nil
            )
        )
    }
    
    func sendWarning(title: String, description: String? = nil) {
        self.publish(message:
            LogMessage(
                type: .warning,
                title: title,
                description: description,
                debugDescription: nil
            )
        )
    }
    
    func sendError(title: String, description: String? = nil) {
        self.publish(message:
            LogMessage(
                type: .error,
                title: title,
                description: description,
                debugDescription: nil
            )
        )
    }
}
