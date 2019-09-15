//
//  SttCollectionReusableView.swift
//  STT
//
//  Created by Peter Standret on 9/15/19.
//  Copyright © 2019 standret. All rights reserved.
//

import Foundation
import UIKit

open class SttCollectionReusableView<Presenter: PresenterType>: UICollectionReusableView, Viewable {
    
    public var presenter: Presenter! {
        didSet {
            prepareBind()
        }
    }
    
    open func prepareBind() {
        presenter.injectView(delegate: self)
    }
}
