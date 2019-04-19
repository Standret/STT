//
//  SttAVAssetExtensions.swift
//  Alamofire
//
//  Created by Peter Standret on 4/19/19.
//

import Foundation
import Photos

public extension AVAsset {
    
    /// URL video on disk
    var url: URL? {
        return (self as? AVURLAsset)?.url
    }
    
    /// render video thumbnail with size
    /// - Parameter size: size of thumbnail
    /// - Returns: thumbnail image or nil if can not create
    func createThumbnail(size: CGSize) -> UIImage? {
        
        let assetImgGenerate = AVAssetImageGenerator(asset: self)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(Float64(1), preferredTimescale: 100)
        
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img).resize(scaledToSize: size)
            return thumbnail
        }
        catch {
            return nil
        }
    }
}
