//
//  BannerHapticGenerator.swift
//  TestApp
//
//  Created by Peter Standret on 9/26/19.
//  Copyright © 2019 Peter Standret. All rights reserved.
//

import UIKit

public enum BannerHaptic {
    case light
    case medium
    case heavy
    case none

    @available(iOS 10.0, *)
    var impactStyle: UIImpactFeedbackGenerator.FeedbackStyle? {
        switch self {
        case .light: return .light
        case .medium: return .medium
        case .heavy: return .heavy
        case .none: return nil
        }
    }
}

open class BannerHapticGenerator: NSObject {

    /**
        Generates a haptic based on the given haptic
        -parameter haptic: The haptic strength to generate when a banner is shown
     */
    open class func generate(_ haptic: BannerHaptic) {
        if #available(iOS 10.0, *) {
            if let style = haptic.impactStyle {
                let feedbackGenerator = UIImpactFeedbackGenerator(style: style)
                feedbackGenerator.prepare()
                feedbackGenerator.impactOccurred()
            }
        }
    }
}
