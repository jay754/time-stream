//
//  ActionsView.swift
//  TimeStream
//
//  Created by appssemble on 16.07.2021.
//

import UIKit

protocol ActionsViewDelegate: AnyObject {
    func actionsDelegateInteract(view: ActionsView)
    func actionsDelegateTip(view: ActionsView)
    func actionsDelegateLike(view: ActionsView)
    func actionsDelegateUnlike(view: ActionsView)
    func actionsDelegateShare(view: ActionsView)
}


class ActionsView: UIView {
    @IBOutlet weak var shareButtonContainer: UIView!
    
    weak var delegate: ActionsViewDelegate?
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var likeButtonContainer: UIView!
    @IBOutlet weak var numberOfLikesContainer: UIView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var tipButtonContainer: UIView!
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    @IBOutlet weak var tipButton: UIButton!
    @IBOutlet weak var interactButtonContainer: UIView!
    @IBOutlet weak var interatButton: UIButton!

    @IBOutlet weak var numberOfInteractsContainer: UIView!
    @IBOutlet weak var numberOfInteractsLabel: UILabel!
    
    private var video: Video?
    
    func populate(video: Video) {
        self.video = video
        
        numberOfLikesLabel.text = "\(video.likes)"
        numberOfInteractsLabel.text = "\(video.postedBy.availableInteractions)"
        
        setLike(active: video.likedByCurrentUser)
        
        if let user = Context.current.user,
           video.postedBy.id == user.id  {
            // Disable tip and interact, video was posted by current user
            tipButtonContainer.isHidden = true
            interactButtonContainer.isHidden = true
            numberOfInteractsContainer.isHidden = true
        }

        // Disable tips
//        if !video.postedBy.tipsEnabled {
            tipButtonContainer.isHidden = true
//        }

        if video.postedBy.availableInteractions <= 0 {
            interactButtonContainer.isHidden = true
            numberOfInteractsContainer.isHidden = true
        }
    }
    
    // MARK: Actions
    
    @IBAction func interact(_ sender: Any) {
        delegate?.actionsDelegateInteract(view: self)
    }
    
    @IBAction func tip(_ sender: Any) {
        delegate?.actionsDelegateTip(view: self)
    }
    
    @IBAction func like(_ sender: Any) {
        if video?.likedByCurrentUser ?? false {
            delegate?.actionsDelegateUnlike(view: self)
            setLike(active: false)
            
        } else {
            delegate?.actionsDelegateLike(view: self)
            
            if let user = Context.current.user {
                // Change the icon, only if we have a logged in user
                setLike(active: true)
            }
        }
    }
    
    @IBAction func share(_ sender: Any) {
        delegate?.actionsDelegateShare(view: self)
    }
    
    // MARK: Private methods
    
    func setLike(active: Bool) {
        if active {
            likeButton.setImage(UIImage(named: "like-button-selected"), for: .normal)
        } else {
            likeButton.setImage(UIImage(named: "like-button"), for: .normal)
        }
    }
}
