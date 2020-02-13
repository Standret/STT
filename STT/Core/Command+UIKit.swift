//
//  Command+UIKit.swift
//  STT
//
//  Created by Peter Standret on 9/21/19.
//  Copyright © 2019 standret. All rights reserved.
//

import Foundation
import UIKit

public extension CommandType {
    
    @discardableResult
    func useIndicator(
        button: UIButton,
        style: UIActivityIndicatorView.Style = .gray,
        color: UIColor = .gray
        ) -> EventDisposable {
        
        let indicator = button.setIndicator()
        indicator.style = style
        indicator.color = color
        indicator.setNeedsDisplay()
        
        let title = button.titleLabel?.text
        var image, disImage: UIImage?

        return self.observe(start: {
            image = button.image(for: .normal)
            disImage = button.image(for: .disabled)
            button.setImage(nil, for: .normal)
            button.setImage(nil, for: .disabled)
            button.setTitle("", for: .disabled)
            button.setNeedsDisplay()
            button.isEnabled = false
            indicator.startAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }) {
            button.setImage(image, for: .normal)
            button.setImage(disImage, for: .disabled)
            button.setTitle(title, for: .disabled)
            button.setNeedsDisplay()
            button.isEnabled = true
            indicator.stopAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    @discardableResult
    func useIndicator(
        view: UIView,
        style: UIActivityIndicatorView.Style = .gray,
        color: UIColor = .gray
        ) -> EventDisposable {
        
        let indicator = view.setIndicator()
        indicator.style = style
        indicator.color = color
        indicator.setNeedsDisplay()
        
        return self.observe(start: {
            indicator.startAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }) {
            indicator.stopAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    @discardableResult
    func useRefresh(
        scrollView: UIScrollView,
        parameter: Any? = nil
        )
        -> (disposable: EventDisposable, refreshControl: UIRefreshControl) {
            
        let refreshControl = SttRefreshControl()
        scrollView.refreshControl = refreshControl
        return (disposable: refreshControl.useCommand(self, parameter: parameter), refreshControl: refreshControl)
    }
}

// This method copy from STT/Extensions/UIViewExtensions
fileprivate extension UIView {

    func setIndicator(
        style: UIActivityIndicatorView.Style = .gray,
        color: UIColor = UIColor.gray
        ) -> UIActivityIndicatorView {
        
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        indicator.style = style
        indicator.color = color
        
        self.addSubview(indicator)
        
        indicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        return indicator
    }
}
