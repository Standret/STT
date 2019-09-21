//
//  AVAssetExtensions.swift
//  Alamofire
//
//  Created by Peter Standret on 4/19/19.
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
