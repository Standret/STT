//
//  SttViewController.swift
//  SttDictionary
//
//  Created by Piter Standret on 6/22/18.
//  Copyright © 2019 Peter Standret <pstandret@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation
import UIKit

open class SttViewController<T: SttViewControllerInjector>: UIViewController {
    
    fileprivate var output: T!
    public var presenter: T {
        get { return output }
        set { output = newValue }
    }
    
    open var heightScreen: CGFloat { return UIScreen.main.bounds.height }
    open var widthScreen: CGFloat { return UIScreen.main.bounds.width }
    
    open var useErrorLabel = true
    open var useVibrationOnError = true
    open var hideNavigationBar = false
    open var hideTabBar = false
    open var customBackBarButton: Bool = false
    
    open var viewError: SttErrorLabel!
    open var barStyle = UIStatusBarStyle.default
    
    fileprivate var parametr: Any?
    fileprivate var callback: ((Any) -> Void)?
    
    private var backgroundLayer: UIView!
    private(set) public var wrappedView = SttWalIndicatorView()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
                
        wrappedView.backgroundColor = .clear
        wrappedView.isHidden = true
        
        view.addSubview(wrappedView)
        wrappedView.edgesToSuperview()
        
        backgroundLayer = UIView()
        backgroundLayer.translatesAutoresizingMaskIntoConstraints = false
        backgroundLayer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        backgroundLayer.alpha = 0
        view.addSubview(backgroundLayer)
        backgroundLayer.edgesToSuperview()
        
        viewError = SttErrorLabel()
        viewError.errorColor = UIColor(red:0.98, green:0.26, blue:0.26, alpha:1)
        viewError.messageColor = UIColor(red: 0.251, green: 0.482, blue: 0.316, alpha:1)
        view.addSubview(viewError)
        viewError.delegate = self
        
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        navigationItem.hidesBackButton = customBackBarButton
        navigationItem.backBarButtonItem = item
        
        navigationController?.interactivePopGestureRecognizer?.addTarget(self, action: #selector(onGesture(sender:)))
    }
    
    // TODO: - Need seperate to decorator
    private var currentTransitionCoordinator: UIViewControllerTransitionCoordinator?
    private var isAppeared: Bool = false
    @objc private func onGesture(sender: UIGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            if let ct = navigationController?.transitionCoordinator {
                currentTransitionCoordinator = ct
            }
        case .cancelled, .ended:
            currentTransitionCoordinator = nil
            backgroundLayer.alpha = 0
        case .possible, .failed:
            break
        @unknown default:
            fatalError()
        }
        
        if let currentTransitionCoordinator = currentTransitionCoordinator {
            if isAppeared {
                backgroundLayer.alpha = 0.75 - currentTransitionCoordinator.percentComplete / 2
            }
            else {
                backgroundLayer.alpha = 0
            }
        }
    }
    
    open func manageWrappedView(color: UIColor, hide: Bool, useIndicator: Bool = true) {
        wrappedView.backgroundColor = color
        wrappedView.isHidden = hide
        if useIndicator {
            if hide {
                wrappedView.stopAnimating()
            }
            else {
                wrappedView.startAnimating()
            }
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isAppeared = true
        
        self.presenter.viewAppearing()
        
        navigationController?.setNavigationBarHidden(hideNavigationBar, animated: true)
        navigationController?.navigationBar.isHidden = hideNavigationBar
    }
    
    fileprivate var isFirstStart = true
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard isFirstStart else { return }
        isFirstStart = false
        
        style()
        bind()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewAppeared()
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isAppeared = false

        presenter.viewDissapearing()
        
        navigationController?.navigationBar.isHidden = false
    }
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.viewDissapeared()
    }

    override open var preferredStatusBarStyle: UIStatusBarStyle { return barStyle }
    
    /// Use this function for decorate elements
    open func style() { }
    
    /// Use this function for subscribing on notification
    
    open func bind() { }
}
