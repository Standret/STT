//
//  Camera.swift
//  STT
//
//  Created by Standret on 22.05.18.
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
import AVFoundation

open class SttCamera: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let applicationName: String
    public let picker = UIImagePickerController()
    public let callBack: (UIImage) -> Void
    public weak var parent: UIViewController?
    
    public init (parent: UIViewController, applicationName: String, handler: @escaping (UIImage) -> Void) {
        self.callBack = handler
        self.parent = parent
        self.applicationName = applicationName
        
        super.init()
        picker.delegate = self
    }
    
    public func takePhoto() {
        picker.sourceType = .camera
        parent?.present(picker, animated: true, completion: nil)
    }
    public func selectPhoto() {
        picker.sourceType = .photoLibrary
        parent?.present(picker, animated: true, completion: nil)
    }
    
    open func showPopuForDecision() {
        if checkPermission() {
            
            parent?.present(createPopupDecision(), animated: true, completion: nil)
        }
        else {
            showPermissionDeniedPopup()
        }
    }
    
    open func createPopupDecision() -> UIAlertController {
        
        let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionController.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (x) in
            self.takePhoto()
        }))
        actionController.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { (x) in
            self.selectPhoto()
        }))
        actionController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        for item in actionController.view.subviews.first!.subviews.first!.subviews {
            item.backgroundColor = UIColor.white
        }
        
        return actionController
    }
    
    private func checkPermission() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized, .notDetermined:
            return true
        case .denied, .restricted:
            return false
        }
    }
    
    private func showPermissionDeniedPopup() {
        
        let alertController = UIAlertController(title: "Change your settings and give \(applicationName) access to your camera and photos.",
                                                message: "Open your app settings, click on \"privacy\" and than \"photos\"",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        alertController.addAction(openAction)
        
        parent?.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - implementation of UIImagePickerControllerDelegate
    
    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        if let _image = image?.fixOrientation() {
            callBack(_image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
