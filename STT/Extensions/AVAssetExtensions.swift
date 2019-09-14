//
//  AVAssetExtensions.swift
//  Alamofire
//
//  Created by Peter Standret on 4/19/19.
//

import Foundation
import Photos

public extension AVAsset {
    
    ///
    /// return URL of asset
    ///
    var url: URL? {
        return (self as? AVURLAsset)?.url
    }
    
    ///
    /// Generate a thumbnail image from given AVAsset
    /// - Parameter size: size of thumbnail
    /// - Parameter time: time of thumbnail
    /// - Returns: thumbnail image or nil if can not create
    /// - Important: may take some time to create thumbnail
    ///
    func createThumbnail(size: CGSize, time: Float64 = 1) -> UIImage? {
        
        let assetImgGenerate = AVAssetImageGenerator(asset: self)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(time, preferredTimescale: 1)
        
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img).resize(scaledToSize: size)
            return thumbnail
        }
        catch {
            return nil
        }
    }
    
    ///
    /// Generate a thumbnail image from given AVAsset and keep aspect ratio
    /// - Parameter width: width of thumbnail
    /// - Parameter time: time of thumbnail
    /// - Returns: thumbnail image or nil if can not create
    /// - Important: may take some time to create thumbnail
    ///
    func createThumbnail(width: CGFloat, time: Float64 = 1) -> UIImage? {
        
        let assetImgGenerate = AVAssetImageGenerator(asset: self)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(time, preferredTimescale: 1)
        
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img).resize(scaledToWidth: width)
            return thumbnail
        }
        catch {
            return nil
        }
    }
    
    ///
    /// Generate a thumbnail image from given AVAsset and keep original size
    /// - Parameter time: time of thumbnail
    /// - Returns: thumbnail image or nil if can not create
    /// - Important: may take some time to create thumbnail
    ///
    func createThumbnail(time: Float64 = 1) -> UIImage? {
        
        let assetImgGenerate = AVAssetImageGenerator(asset: self)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(time, preferredTimescale: 1)
        
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        }
        catch {
            return nil
        }
    }
}
