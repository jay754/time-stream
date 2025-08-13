//
//  CharityTableViewCell.swift
//  TimeStream
//
//  Created by appssemble on 12.08.2021.
//

import UIKit

class CharityTableViewCell: UITableViewCell {

    @IBOutlet weak var charityImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var selectionButton: UIButton!
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        set(selected: false)
    }
    
    // MARK: Public methods
    
    func populate(charity: Charity) {
        charityImageView.setImage(url: charity.imageURL)
        nameLabel.text = charity.title
        detailsLabel.text = charity.subtitle
        
        set(selected: false)
    }
    
    func set(selected: Bool) {
        if selected {
            selectionButton.setImage(UIImage(named: "selected-filled-icon"), for: .normal)
            
        } else {
            selectionButton.setImage(UIImage(named: "selected-unfilled-icon"), for: .normal)
        }
    }
}
