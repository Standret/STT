//
//  FloatingNotificationBanner.swift
//  TestApp
//
//  Created by Peter Standret on 9/25/19.
//  Copyright © 2019 Peter Standret. All rights reserved.
//

import Foundation
import UIKit

public enum QueuePosition: Int {
    case back
    case front
}

public enum BannerPosition: Int {
    case bottom
    case top
}

public enum BannerStyle {
    case danger
    case info
    case customView
    case success
    case warning
}

fileprivate extension UIApplication {
    
    var appWindow: UIWindow {
        if #available(iOS 13.0, *) {
            let connectedScenes = UIApplication.shared.connectedScenes
            for scene in connectedScenes {
                if scene.activationState == .foregroundActive {
                    let windowScene = scene as? UIWindowScene
                    return windowScene?.windows.first! ?? UIWindow()
                }
            }
        }
        
        return UIApplication.shared.delegate!.window!!
    }
}

fileprivate extension UIView {
    
    func _setShadow(color: UIColor, offset: CGSize = CGSize.zero, opacity: Float = 0.2, radius: Float = 1) {
        
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
        layer.shadowRadius = CGFloat(radius)
    }
}

public protocol NotificationBannerType: AnyObject {
    
    var bannerPosition: BannerPosition { get }
    
    var isDisplaying: Bool { get }
    var isSuspended: Bool { get }
    
    var title: String { get }
    var descriptionText: String? { get }
    
    func show(
        queuePosition: QueuePosition,
        bannerPosition: BannerPosition,
        queue: NotificationBannerQueue,
        on viewController: UIViewController?
    )
    
    func show(
        placeOnQueue: Bool,
        queuePosition: QueuePosition,
        bannerPosition: BannerPosition
    )
    
    func dismiss()
    
    func suspend()
    func resume()
}

public class FloatingNotificationBanner: UIView, NotificationBannerType {
    
    public var title: String { return lblTitle.text ?? "" }
    public var descriptionText: String? { return lblDescription.text }
    public var debugDescriptionText: String?
    
    /// The type of haptic to generate when a banner is displayed
    public var haptic: BannerHaptic = .heavy
    
    /// If true, notification will dismissed when swiped up
    public var dismissOnSwipeUp: Bool = true
    
    /// The time before the notificaiton is automatically dismissed
    public var duration: TimeInterval = 5.0
    
    /// If false, the banner will not be dismissed until the developer programatically dismisses it
    public var autoDismiss: Bool = true {
        didSet {
            if !autoDismiss {
                dismissOnSwipeUp = false
            }
        }
    }
    
    /// Closure that will be executed if the notification banner is tapped
    public lazy var onTap: (() -> Void) = { [unowned self] in
        let alertController = UIAlertController(title: self.lblTitle.text, message: (self.lblDescription.text ?? "") + "\n-----------\n" + (self.debugDescriptionText ?? ""), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        UIApplication.shared.appWindow.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    /// Responsible for positioning and auto managing notification banners
    public var bannerQueue: NotificationBannerQueue = NotificationBannerQueue.shared
    
    /// Used by the banner queue to determine wether a notification banner was placed in front of it in the queue
    public internal(set) var isDisplaying: Bool = false
    
    /// Used by the banner queue to determine wether a notification banner was placed in front of it in the queue
    public internal(set) var isSuspended: Bool = false
    
    /// The view controller to display the banner on. This is useful if you are wanting to display a banner underneath a navigation bar
    internal weak var parentViewController: UIViewController?
    
    /// The default offset for spacerView top or bottom
    internal var spacerViewDefaultOffset: CGFloat = 10.0
    
    /// The default padding between edges and views
    internal var padding: CGFloat = 12.0
    
    private var contentView: UIView!
    private(set) var lblTitle: UILabel!
    private(set) var lblDescription: UILabel!
    
    private let style: BannerStyle
    private let bannerAppearance: BannerAppearanceType
    private(set) public var bannerPosition: BannerPosition = .top
    
    private var cnstrHidden: NSLayoutConstraint!
    
    public init(style: BannerStyle,
         title: String?,
         description: String?,
         debugDescription: String?,
         bannerAppearance: BannerAppearanceType) {
        
        self.style = style
        self.bannerAppearance = bannerAppearance
        self.debugDescriptionText = debugDescription
        
        super.init(frame: .zero)
        
        initContentView()
        initGesture()
        
        lblTitle.text = title
        lblDescription.text = description
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.clipsToBounds = true
    }
    
    public func show(
        queuePosition: QueuePosition,
        bannerPosition: BannerPosition,
        queue: NotificationBannerQueue,
        on viewController: UIViewController?
    ) {
        
        parentViewController = viewController
        bannerQueue = queue
        show(placeOnQueue: true, queuePosition: queuePosition, bannerPosition: bannerPosition)
    }
    
    public func show(placeOnQueue: Bool,
                     queuePosition: QueuePosition = .back,
                     bannerPosition: BannerPosition = .top
    ) {
        
        guard !isDisplaying else { return }
        
        self.bannerPosition = bannerPosition
        
        
        if placeOnQueue {
            bannerQueue.addBanner(self, queuePosition: queuePosition)
        }
        else {
            
            isDisplaying = true
            
            let appWindow = UIApplication.shared.appWindow
            
            if let parentViewController = parentViewController {
                parentViewController.view.addSubview(self)
            }
            else {
                appWindow.addSubview(self)
                appWindow.windowLevel = UIWindow.Level.statusBar + 1
            }
            
            self.makeConstraints(for: bannerPosition)
            cnstrHidden.isActive = false
            
            UIView.animate(withDuration: 0.7,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 1,
                           options: [.curveLinear, .allowUserInteraction],
                           animations: {
                            BannerHapticGenerator.generate(self.haptic)
                            self.superview?.layoutSubviews()
            }) { (completed) in
                
                if !self.isSuspended && self.autoDismiss {
                    self.perform(#selector(self.dismiss), with: nil, afterDelay: self.duration)
                }
            }
        }
    }
    
    /**
     Dismisses the NotificationBanner and shows the next one if there is one to show on the queue
     */
    
    @objc
    public func dismiss() {
        
        guard isDisplaying else { return }
        
        cnstrHidden.isActive = true
        
        UIView.animate(withDuration: 0.7, animations: {
            self.superview?.layoutSubviews()
        }) { _ in
            self.removeFromSuperview()
            self.isDisplaying = false
            
            self.bannerQueue.showNext(callback: { (isEmpty) in
                if isEmpty {
                    UIApplication.shared.appWindow.windowLevel = UIWindow.Level.normal
                }
            })
        }
    }
    
    /**
     Suspends a notification banner so it will not be dismissed. This happens because a new notification banner was placed in front of it on the queue.
     */
    public func suspend() {
        if autoDismiss {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(dismiss), object: nil)
            isSuspended = true
            isDisplaying = false
        }
    }
    
    /**
     Resumes a notification banner immediately.
     */
    public func resume() {
        if autoDismiss {
            self.perform(#selector(dismiss), with: nil, afterDelay: self.duration)
            isSuspended = false
            isDisplaying = true
        }
    }
    
    private func initContentView() {
        contentView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = bannerAppearance.background(for: style)
        
        contentView.layer.cornerRadius = 10
        contentView._setShadow(color: .darkGray, offset: CGSize(width: 0, height: 2), opacity: 0.6, radius: 6)
        
        addSubview(contentView)
        
        contentView.topAnchor.constraint(equalTo: self.topAnchor, constant: spacerViewDefaultOffset).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -spacerViewDefaultOffset).isActive = true
        contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: spacerViewDefaultOffset).isActive = true
        contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -spacerViewDefaultOffset).isActive = true
        
        initTitle()
        initDescription()
    }
    
    private func initGesture() {
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeGestureRecognizer))
        swipeUpGesture.direction = .up
        addGestureRecognizer(swipeUpGesture)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeGestureRecognizer))
        swipeDownGesture.direction = .down
        addGestureRecognizer(swipeDownGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapGestureRecognizer))
        addGestureRecognizer(tapGesture)
    }
    
    private func initTitle() {
        lblTitle = UILabel()
        lblTitle.translatesAutoresizingMaskIntoConstraints = false
        lblTitle.numberOfLines = 1
        
        lblTitle.font = bannerAppearance.titleFont(for: style)
        lblTitle.textColor = bannerAppearance.titleTextColor(for: style)
        
        contentView.addSubview(lblTitle)
        
        lblTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding).isActive = true
        lblTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding).isActive = true
        lblTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding).isActive = true
        
        lblTitle.addConstraint(
            NSLayoutConstraint(
                item: lblTitle as Any,
                attribute: .height,
                relatedBy: .greaterThanOrEqual,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: 0
            )
        )
    }
    
    private func initDescription() {
        lblDescription = UILabel()
        lblDescription.translatesAutoresizingMaskIntoConstraints = false
        
        lblDescription.font = bannerAppearance.descriptionFont(for: style)
        lblDescription.textColor = bannerAppearance.descriptionTextColor(for: style)
        
        lblDescription.numberOfLines = 3
        
        contentView.addSubview(lblDescription)
        
        lblDescription.topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: 0).isActive = true
        lblDescription.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding).isActive = true
        lblDescription.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding).isActive = true
        lblDescription.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding).isActive = true
        
        lblDescription.addConstraint(
            NSLayoutConstraint(
                item: lblDescription as Any,
                attribute: .height,
                relatedBy: .greaterThanOrEqual,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: 0
            )
        )
    }
    
    private func makeConstraints(for position: BannerPosition) {
        guard let superview = self.superview else { fatalError("Incorrect initialization") }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor).isActive = true
        
        self.addConstraint(
            NSLayoutConstraint(
                item: self as Any,
                attribute: .height,
                relatedBy: .greaterThanOrEqual,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: 0
            )
        )
        
        var cnstrVisible: NSLayoutConstraint
        if position == .top {
            cnstrVisible = self.topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor)
            cnstrHidden = self.topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor)
        }
        else {
            cnstrVisible = self.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor)
            cnstrHidden = self.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor)
        }
        
        cnstrVisible.priority = UILayoutPriority(999)
        cnstrVisible.isActive = true
        
        self.layoutIfNeeded()
        if position == .top {
            cnstrHidden.constant = -(self.bounds.size.height + 60)
        }
        else {
            cnstrHidden.constant = superview.bounds.height
        }
        
        cnstrHidden.isActive = true
        superview.layoutIfNeeded()
    }
    
    /**
     Called when a notification banner is tapped
     */
    @objc
    private dynamic func onTapGestureRecognizer() {
        onTap()
    }
    
    /**
     Called when a notification banner is swiped up
     */
    @objc
    private dynamic func onSwipeGestureRecognizer(_ gesture: UISwipeGestureRecognizer) {
        if dismissOnSwipeUp {
            if gesture.direction == .up && bannerPosition == .top ||
                gesture.direction == .down && bannerPosition == .bottom {
                dismiss()
            }
            else {
                onTap()
            }
        }
    }
}
