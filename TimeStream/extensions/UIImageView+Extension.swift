//
//  UIImageView+Extension.swift
//  TimeStream
//
//  Created by appssemble on 15.07.2021.
//

import UIKit
import Kingfisher

extension UIImageView {
    func setUserImage(url:URL?) {
        if image != nil {
            kf.setImage(with: url, options: [
                .scaleFactor(UIScreen.main.scale),
            ])
        } else {
            kf.setImage(with: url, options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.5))
            ])
        }
    }
    
    func setImage(url:URL?) {
        if image != nil {
            kf.setImage(with: url, options: [
                .scaleFactor(UIScreen.main.scale),
            ])
        } else {
            kf.setImage(with: url, options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.5))
            ])
        }
    }

}
