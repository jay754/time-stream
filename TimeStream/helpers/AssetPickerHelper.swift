//
//  ImagePickerHelper.swift
//  TimeStream
//
//  Created by appssemble on 12.07.2021.
//

import Foundation
import UIKit
import AVFoundation
import Photos
import MobileCoreServices

enum ImagePickerType {
    case camera
    case library
}

protocol AssetPickerProtocol: class {
    func didPickImage(helper: AssetPickerHelper, image: UIImage)
    func didPickVideo(helper: AssetPickerHelper, url: URL)
}

// To have them as optionals
extension AssetPickerProtocol {
    func didPickImage(helper: AssetPickerHelper, image: UIImage) {
        
    }
    
    func didPickVideo(helper: AssetPickerHelper, url: URL) {
        
    }
}

fileprivate class Picker: UIImagePickerController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
}

class AssetPickerHelper: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
    
    weak var delegate: AssetPickerProtocol?
    
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    private var picksPhoto = true
    
    // MARK: Public methods
    
    func pickImage() {
        let alertController = UIAlertController(title: "Location", message: "From where do you wish to upload the picture?", preferredStyle: .alert)
        
        let camera = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.pickImage(sourceType: .camera)
        }
        
        let library = UIAlertAction(title: "Library", style: .default) { (_) in
            self.pickImage(sourceType: .library)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(camera)
        alertController.addAction(library)
        alertController.addAction(cancel)
        
        viewController?.present(alertController, animated: true, completion: nil)
    }
    
    func pickImageFromLibrary() {
        picksPhoto = true
        
        self.pickImage(sourceType: .library)
    }
    
    func pickVideoFromLibrary() {
        picksPhoto = false
        
        let picker = Picker()
        picker.delegate = self
        picker.transitioningDelegate = self

        AppearanceHelper.configureNavBarAssetPicking()
        if libraryAvailable() {
            picker.sourceType = .photoLibrary
            picker.mediaTypes = [kUTTypeMovie as String]
        } else {
            AppearanceHelper.configureNavigationBar()
            return
        }

        viewController?.present(picker, animated: true) {
            picker.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    // MARK: Image picker delegate
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        AppearanceHelper.configureNavigationBar()
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[.originalImage] as? UIImage {
            delegate?.didPickImage(helper: self, image: image)
        }
        
        if let videoURL = info[.mediaURL] as? NSURL {
            delegate?.didPickVideo(helper: self, url: videoURL as URL)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        AppearanceHelper.configureNavigationBar()
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Transition delegate
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        AppearanceHelper.configureNavigationBar()
        return nil
    }
    
    // MARK: Private methods
    
    private func pickImage(sourceType: ImagePickerType) {
        let picker = Picker()
        picker.delegate = self
        picker.transitioningDelegate = self
        
        AppearanceHelper.configureNavBarAssetPicking()
        switch sourceType {
        case .camera:
            if cameraAvailable(success: {
                self.pickImage(sourceType: .camera)
            }) {
                picker.sourceType = .camera
            } else {
                AppearanceHelper.configureNavigationBar()
                return
            }
        case .library:
            if libraryAvailable() {
                picker.sourceType = .photoLibrary
                picker.mediaTypes = ["public.image"]
            } else {
                AppearanceHelper.configureNavigationBar()
                return
            }
        }
        
        viewController?.present(picker, animated: true) {
            picker.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    func cameraAvailable(success: @escaping () -> Void) -> Bool {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
        case .authorized:
            return true
        case .denied:
            permissionDeniedCamera()
        case .notDetermined:
            requestAccessCamera {
                success()
            }
        default:
            requestAccessCamera {
                success()
            }
        }
        
        return false
    }
    
    private func libraryAvailable() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            return true
        case .denied:
            permissionDeniedLibrary()
        case .notDetermined:
            requestPhotoLibraryAccess()
        default:
            requestPhotoLibraryAccess()
        }
        
        return false
    }
    
    private func permissionDeniedCamera() {
        let alert = UIAlertController(title: "Error",
                                      message: "Camera access required for capturing photos!",
                                      preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            
        }))
        
        viewController?.present(alert, animated: true, completion: nil)
    }
    
    private func permissionDeniedLibrary() {
        let alert = UIAlertController(title: "Error",
                                      message: "Photo library access required!",
                                      preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }))
        
        viewController?.present(alert, animated: true, completion: nil)
    }
    
    private func requestAccessCamera(success : @escaping () -> Void) {
        if let _ = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted: Bool) in
                if granted {
                    DispatchQueue.main.async {
                        success()
                    }
                }
            }
        }
    }
    
    private func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) in
            if status == .authorized {
                DispatchQueue.main.async {
                    if self.picksPhoto {
                        self.pickImage(sourceType: .library)
                    } else {
                        self.pickVideoFromLibrary()
                    }
                }
            }
        }
    }
    
    private func resizeImage(image: UIImage) -> UIImage? {
        let targetWidth: CGFloat = 512.0
        let scaleFactor = targetWidth / image.size.width
        let height = image.size.height * scaleFactor
        
        let newSize = CGSize(width: targetWidth, height: height)
        UIGraphicsBeginImageContext(newSize)
        
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height), blendMode: .normal, alpha: 1.0)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let image = newImage {
            return image
        }
        
        return nil
    }
}
