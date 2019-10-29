//
//  UIImageView+SDWebImage.swift
//  STT
//
//  Created by Peter Standret on 9/28/19.
//  Copyright © 2019 standret. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

public extension UIImageView {
    
    func loadImage(url: String?, placeholder: String?, shouldLoadPlaceholder: Bool) {
        if let url = url?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            
            var placeHolderImage: UIImage?
            if shouldLoadPlaceholder {
                if let placeholder = placeholder {
                    placeHolderImage = UIImage(named: placeholder)
                }
            }
            else {
                placeHolderImage = self.image
            }
            
            self.sd_setImage(
                with: URL(string: url),
                placeholderImage: placeHolderImage,
                options: [.decodeFirstFrameOnly, .refreshCached],
                completed: { [weak self] (image: UIImage?, error: Error?, _, _) in
                    
                    if error == nil && image != nil {
                        self?.image = image
                    }
                    else if error != nil {
                        NSLog("[SDWEBIMAGELOADER] \(error!)")
                    }
                    
            })
        }
        else if let placeholder = placeholder {
            self.image = UIImage(named: placeholder)
        }
    }
}
