//
//  BorderView.swift
//  TimeStream
//
//  Created by appssemble on 13.08.2021.
//

import UIKit

class BorderedView : UIView {
    
    @IBInspectable var color: UIColor = UIColor.white
    @IBInspectable var borderWidth: CGFloat = 1

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        layer.borderColor = color.cgColor
        layer.borderWidth = borderWidth
    }
}
