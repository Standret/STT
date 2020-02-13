//
//  BannerQueue.swift
//  TestApp
//
//  Created by Peter Standret on 9/27/19.
//  Copyright © 2019 Peter Standret. All rights reserved.
//

import Foundation

open class NotificationBannerQueue {
    
    /// The default instance of the NotificationBannerQueue
    public static let shared = NotificationBannerQueue()
    
    /// The notification banners currently placed on the queue
    private(set) var banners: [NotificationBannerType] = []
    
    /// The current number of notification banners on the queue
    public var numberOfBanners: Int {
        return banners.count
    }
    
    /**
        Adds a banner to the queue
        -parameter banner: The notification banner to add to the queue
        -parameter queuePosition: The position to show the notification banner. If the position is .front, the
        banner will be displayed immediately
    */
    func addBanner(_ banner: NotificationBannerType, queuePosition: QueuePosition) {
        
        let existingBanner = banners.first(where: { $0.title == banner.title && $0.descriptionText == banner.descriptionText })
        guard existingBanner == nil else {
            existingBanner?.suspend()
            existingBanner?.resume()
            return
        }
        
        if queuePosition == .back {
            banners.append(banner)
            
            if banners.firstIndex(where: { $0 === banner }) == 0 {
                banner.show(
                    placeOnQueue: false,
                    queuePosition: .back,
                    bannerPosition: banner.bannerPosition
                )
            }
            
        }
        else {
            banner.show(
                placeOnQueue: false,
                queuePosition: .back,
                bannerPosition: banner.bannerPosition
            )
            
            if let firstBanner = banners.first {
                firstBanner.suspend()
            }
            
            banners.insert(banner, at: 0)
        }
        
    }
    
    /**
        Removes a banner from the queue
        -parameter banner: A notification banner to remove from the queue.
     */
    func removeBanner(_ banner: NotificationBannerType) {
        
        if let index = banners.firstIndex(where: { $0 === banner }) {
            banners.remove(at: index)
        }
    }
    
    /**
        Shows the next notificaiton banner on the queue if one exists
        -parameter callback: The closure to execute after a banner is shown or when the queue is empty
    */
    func showNext(callback: ((_ isEmpty: Bool) -> Void)) {

        if !banners.isEmpty {
            banners.removeFirst()
        }
        guard let banner = banners.first else {
            callback(true)
            return
        }
        
        if banner.isSuspended {
            banner.resume()
        }
        else {
            banner.show(
                placeOnQueue: false,
                queuePosition: .back,
                bannerPosition: banner.bannerPosition
            )
        }
        
        callback(false)
    }
    
    /**
        Removes all notification banners from the queue
    */
    public func removeAll() {
        banners.removeAll()
    }
}

