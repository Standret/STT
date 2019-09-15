//
//  SttTableViewCell.swift
//  STT
//
//  Created by Peter Standret on 9/15/19.
//  Copyright © 2019 standret. All rights reserved.
//

import Foundation
import UIKit

open class SttTableViewCell<Presenter: PresenterType>: UITableViewCell, Viewable {
    
    public var presenter: Presenter! {
        didSet {
            self.prepareBind()
        }
    }
    
    open func prepareBind() {
        presenter.injectView(delegate: self)
    }
}
