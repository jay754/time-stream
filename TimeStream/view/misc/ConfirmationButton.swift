//
//  ConfirmationButton.swift
//  TimeStream
//
//  Created by appssemble on 12.07.2021.
//

import UIKit

class ConfirmationButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.accent
        setTitleColor(UIColor.white, for: .normal)
        
        titleLabel?.font = UIFont.defaultFontSemiBold(ofSize: 17)
        layer.cornerRadius = 12
    }
    
    func set(active: Bool) {
        if active {
            isUserInteractionEnabled = true
            alpha = 1
        } else {
            isUserInteractionEnabled = false
            alpha = 0.5
        }
    }
}
