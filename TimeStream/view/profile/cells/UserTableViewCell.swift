//
//  UserTableViewCell.swift
//  TimeStream
//
//  Created by appssemble on 17.08.2021.
//

import UIKit

protocol UserTableViewCellDelegate: class {
    func didTapFollow(cell: UserTableViewCell, user: User)
    func didTapUnfollow(cell: UserTableViewCell, user: User)
}

class UserTableViewCell: UITableViewCell {
    
    weak var delegate: UserTableViewCellDelegate?

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var unfollowButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    
    private var user: User?
    
    // MARK: Methods
    
    static var val = 0
    
    func populate(user: User, currentUser: User?) {
        self.user = user
        userImageView.setUserImage(url: user.photoURL)
        nameLabel.text = user.name
        
        UserTableViewCell.val += 1
        if currentUser?.followsUser(id: user.id) ?? false {
            unfollowButton.isHidden = false
            followButton.isHidden = true
        } else {
            unfollowButton.isHidden = true
            followButton.isHidden = false
        }
        
        if currentUser?.id == user.id {
            unfollowButton.isHidden = true
            followButton.isHidden = true
        }
    }

    // MARK: Actions
    
    @IBAction func unfolowTapped(_ sender: Any) {
        guard let user = user else {
            return
        }
        
        delegate?.didTapUnfollow(cell: self, user: user)
    }
    
    @IBAction func followTapped(_ sender: Any) {
        guard let user = user else {
            return
        }
        
        delegate?.didTapFollow(cell: self, user: user)
    }
}
