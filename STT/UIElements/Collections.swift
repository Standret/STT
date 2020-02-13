//
//  Collections.swift
//  STT
//
//  Created by Peter Standret on 12.10.2019.
//  Copyright © 2019 standret. All rights reserved.
//

import Foundation
import UIKit

open class SttCollectionView: UICollectionView {
    
    private var contentSizeChangedPublisher = EventPublisher<CGSize>()
    public var contentSizeChanged: Event<CGSize> { return contentSizeChangedPublisher }
    
    override open var contentSize: CGSize {
        didSet {
            contentSizeChangedPublisher.invoke(contentSize)
        }
    }
}

open class SttTableView: UITableView {
    
    private var contentSizeChangedPublisher = EventPublisher<CGSize>()
    public var contentSizeChanged: Event<CGSize> { return contentSizeChangedPublisher }
    
    override open var contentSize: CGSize {
        didSet {
            contentSizeChangedPublisher.invoke(contentSize)
        }
    }
}
