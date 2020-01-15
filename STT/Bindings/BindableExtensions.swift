//
//  BindableExtensions.swift
//  STT
//
//  Created by Peter Standret on 9/22/19.
//  Copyright © 2019 standret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: UILabel {
    
    /// Bindable sink for `text` property.
    public var text: Binder<String> {
        return Binder(self.base) { label, text in
            label.text = text
        }
    }
}
