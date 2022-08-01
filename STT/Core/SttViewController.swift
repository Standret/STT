//
//  SttViewController.swift
//  STT
//
//  Created by Peter Standret on 9/13/19.
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

///
/// The view controller for auto manage presenter lifecycle
///
open class SttViewController<Presenter: PresenterType>: UIViewController, ViewControllerType {
    
    open var presenter: Presenter!
    
    open var customBackBarButton: Bool = false
    open var hideNavigationBar = false
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewCreated()
        navigationItem.hidesBackButton = customBackBarButton
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewAppearing()
        navigationController?.setNavigationBarHidden(hideNavigationBar, animated: true)
        navigationController?.navigationBar.isHidden = hideNavigationBar
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewAppeared()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.viewDisappearing()
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.viewDisappeared()
    }
    
    private var firstStart = true
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard firstStart else { return }
        firstStart = false
        
        style()
        bind()
    }
    
    ///
    /// manage apearance of view
    /// - Important: do not call basic version
    ///
    open func style() { }
    
    ///
    /// manage all subsribtions
    /// - Important: do not call basic version. Call before style()
    ///
    open func bind() { }
}

///
/// The view controller for auto manage presenter lifecycle
///
open class SttTabBarController<Presenter: PresenterType>: UITabBarController, ViewControllerType {

    open var presenter: Presenter!

    open var customBackBarButton: Bool = false
    open var hideNavigationBar = false

    override open func viewDidLoad() {
        super.viewDidLoad()
       // presenter.viewCreated()
        navigationItem.hidesBackButton = customBackBarButton
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewAppearing()
        navigationController?.setNavigationBarHidden(hideNavigationBar, animated: true)
        navigationController?.navigationBar.isHidden = hideNavigationBar
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewAppeared()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.viewDisappearing()
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.viewDisappeared()
    }

    private var firstStart = true
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard firstStart else { return }
        firstStart = false

        style()
        bind()
    }

    ///
    /// manage apearance of view
    /// - Important: do not call basic version
    ///
    open func style() { }

    ///
    /// manage all subsribtions
    /// - Important: do not call basic version. Call before style()
    ///
    open func bind() { }
}
