//
//  ExploreCreatorCollectionViewCell.swift
//  TimeStream
//
//  Created by appssemble on 07.12.2021.
//

import UIKit

protocol ExploreCreatorCollectionViewCellDelegate: AnyObject {
    func exploreCreatorFollowCreator(cell: ExploreCreatorCollectionViewCell, user: User)
}

class ExploreCreatorCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: ExploreCreatorCollectionViewCellDelegate?
    
    @IBOutlet weak var creatorName: UILabel!
    @IBOutlet weak var creatorImageView: UIImageView!
    @IBOutlet weak var followButton: UIButton!

    private var user: User?

    
    func populate(user: User) {
        self.user = user
        
        creatorName.text = user.name
        creatorImageView.setUserImage(url: user.photoURL)
        followButton.isHidden = false
        
        guard let current = Context.current.user else {
            return
        }
        
        if current.followsUser(id: user.id) || current.id == user.id {
            followButton.isHidden = true
        }
    }

    @IBAction func followCreator(_ sender: Any) {
        guard let user = user else {
            return
        }

        delegate?.exploreCreatorFollowCreator(cell: self, user: user)
    }
}
