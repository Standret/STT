//
//  SttCollectionReusableView.swift
//  STT
//
//  Created by Standret on 30.05.18.
//  Copyright © 2018 com.yurt.YURT. All rights reserved.
//

import Foundation
import UIKit

open class SttCollectionReusableView<T: SttViewInjector>: UICollectionReusableView, SttViewable {
    
    public var presenter: T! {
        didSet {
            prepareBind()
        }
    }
    
    open func prepareBind() {
        presenter.injectView(delegate: self)
    }
}
