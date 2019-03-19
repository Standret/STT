//
//  SttInteractionBindingContext.swift
//  STT
//
//  Created by Peter Standret on 3/19/19.
//  Copyright © 2019 standret. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

public enum SttInteractionType {
    case tap
}

public struct SttBindingInteractionData {
    let type: SttInteractionType
    let target: UIView
}

public extension UIView {
    
    public func tap() -> SttBindingInteractionData {
        return SttBindingInteractionData(type: .tap, target: self)
    }
    
}

public class SttInteractionBindingContext<TViewController: AnyObject>: SttGenericBindingContext<TViewController, String?> {
    
    internal init (viewController: TViewController, data: SttBindingInteractionData) {
        
        super.init(vc: viewController)
        
        switch data.type {
        case .tap:
            data.target.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap(_:))))
        }
    }
    
    @objc
    private func onTap(_ sender: UIView) {
        self.command.execute(parametr: parametr)
    }
}
