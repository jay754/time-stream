//
//  DeleteMeUserTableViewCell.swift
//  TimeStream
//
//  Created by appssemble on 15.11.2021.
//

import UIKit

class DeleteMeUserTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    func populate(user: User) {
        userImageView.setUserImage(url: user.photoURL)
        nameLabel.text = user.name
    }
}
