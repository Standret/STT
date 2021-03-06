//
//  CachedImageView.swift
//  STT
//
//  Created by Peter Standret on 9/28/19.
//  Copyright © 2019 standret. All rights reserved.
//

import Foundation
import UIKit

public class CachedImageView: UIImageView {

    public var imageData: Image? {
        didSet {
            self.sd_cancelCurrentImageLoad()
            if let imageUrl = imageData?.url, !String.__isWhiteSpace__(imageUrl) {
                self.loadImage(
                    url: imageUrl,
                    placeholder: placeholderType.name,
                    shouldLoadPlaceholder: imageData!.shouldLoadPlaceholder
                )
            }
            else if let data = imageData?.data {
                self.image = UIImage(data: data)
            }
            else if let placeholderImage = placeholderType.name {
                self.image = UIImage.init(named: placeholderImage)
            }
        }
    }

    public var placeholderType: ImagePlaceholderType = .usual
}

// Copy from STT/Extensions/StringExtensions
fileprivate extension String {
    static func __isWhiteSpace__(_ string: String?) -> Bool {
        return (string ?? "").trimmingCharacters(in: .whitespaces).isEmpty
    }
}
