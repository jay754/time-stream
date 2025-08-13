//
//  HashtagItem.swift
//  TimeStream
//
//  Created by appssemble on 22.07.2021.
//

import UIKit


class ProfileHashtagItem: UIView {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var containerView: UIView!
  
    // MARK: Methods
    
    func populate(item: String) {
        label.text = "#" + item
    }
}
