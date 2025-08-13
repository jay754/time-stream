//
//  UIImage+Extension.swift
//  TimeStream
//
//  Created by appssemble on 03.07.2021.
//

import Foundation
import UIKit

extension UIImage {
    func resizeImage(targetHeight: CGFloat) -> UIImage? {
        let ratio = targetHeight / size.height
        return resize(withRatio: ratio)
    }
    
    func activeTabBarImage() -> UIImage? {
        return resizeImage(targetWidth: 20)
    }
    
    func inactiveTabBarImage() -> UIImage? {
        return resizeImage(targetHeight: 20)
    }
    
    func activeTabBarImageSmall() -> UIImage? {
        return resizeImage(targetWidth: 17)
    }
    
    func inactiveTabBarImageSmall() -> UIImage? {
        return resizeImage(targetHeight: 17)
    }
    
    func resizeImage(targetWidth: CGFloat) -> UIImage? {
        let ratio = targetWidth / size.width
        return resize(withRatio: ratio)
    }
    
    class func imageFromColor(color: UIColor) -> UIImage {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 1.0, height: 1.0))
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        return image!
    }
    
    private func resize(withRatio ratio: CGFloat) -> UIImage? {
        let size = self.size
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage?.withRenderingMode(.alwaysOriginal)
    }
}
