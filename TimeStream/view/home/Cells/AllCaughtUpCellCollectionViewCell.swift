//
//  AllCaughtUpCellCollectionViewCell.swift
//  TimeStream
//
//  Created by appssemble on 22.07.2021.
//

import UIKit

class AllCaughtUpCellCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var personalityImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var expertiseLabel: UILabel!
    @IBOutlet weak var labelsDistanceConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    // MARK: Methods
    
    func populate(name: String, expertise: String, isMain: Bool = false) {
        nameLabel.text = name
        expertiseLabel.text = expertise
        
        var font: UIFont!
        if isMain {
            labelsDistanceConstraint.constant = 8
            font = UIFont(name: nameLabel.font.fontName, size: 13)
        } else {
            labelsDistanceConstraint.constant = 4
            font = UIFont(name: nameLabel.font.fontName, size: 6)
        }
        
        nameLabel.font = font
        expertiseLabel.font = font
    }
    
}
