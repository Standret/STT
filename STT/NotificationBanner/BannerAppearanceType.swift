//
//  BannerAppearanceType.swift
//  TestApp
//
//  Created by Peter Standret on 9/27/19.
//  Copyright © 2019 Peter Standret. All rights reserved.
//

import Foundation
import UIKit

public protocol BannerAppearanceType {
    func background(for style: BannerStyle) -> UIColor
    
    func titleTextColor(for style: BannerStyle) -> UIColor
    func descriptionTextColor(for style: BannerStyle) -> UIColor
    
    func titleFont(for style: BannerStyle) -> UIFont
    func descriptionFont(for style: BannerStyle) -> UIFont
}

public class BannerAppearance: BannerAppearanceType {
    
    public func background(for style: BannerStyle) -> UIColor {
        switch style {
        case .danger:   return UIColor(red:0.90, green:0.31, blue:0.26, alpha:1.00)
        case .info:     return UIColor(red:0.23, green:0.60, blue:0.85, alpha:1.00)
        case .customView:     return UIColor.clear
        case .success:  return UIColor(red:0.22, green:0.80, blue:0.46, alpha:1.00)
        case .warning:  return UIColor(red:1.00, green:0.66, blue:0.16, alpha:1.00)
        }
    }
    
    public init() { }
    
    public func titleTextColor(for style: BannerStyle) -> UIColor {
        return .white
    }
       
    public func descriptionTextColor(for style: BannerStyle) -> UIColor {
        return .white
    }
    
    public func titleFont(for style: BannerStyle) -> UIFont {
        return UIFont.systemFont(ofSize: 18, weight: .bold)
    }
    
    public func descriptionFont(for style: BannerStyle) -> UIFont {
        return UIFont.systemFont(ofSize: 15, weight: .regular)
    }
}
