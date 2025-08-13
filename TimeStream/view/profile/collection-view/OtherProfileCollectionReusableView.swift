//
//  OtherProfileCollectionReusableView.swift
//  TimeStream
//
//  Created by appssemble on 13.08.2021.
//

import UIKit

protocol OtherProfileCollectionReusableViewDelegate: class {
    func otherProfileAddTip()
    func otherProfileInteract()
    func otherProfileFollowers()
    func otherProfileFollowing()
    func otherProfileFilterChanged()
}

class OtherProfileCollectionReusableView: UICollectionReusableView {
    
    weak var delegate: OtherProfileCollectionReusableViewDelegate?

    @IBOutlet weak var topGradientView: UIView!
    @IBOutlet weak var bottomGradientView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var hashtagsContainer: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var remainingInteractsLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var interactionsLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var interactButton: UIButton!
    @IBOutlet weak var charityImageView: UIImageView!
    @IBOutlet weak var chairtyLabel: UILabel!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var followUnfollowButton: UIButton!
    
    @IBOutlet weak var tipButtonCharity: UIButton!
    @IBOutlet weak var tipButtonSimple: UIButton!
    @IBOutlet weak var moneyIcon: UIImageView!
    @IBOutlet weak var feeWithDontanationContainer: UIView!
    @IBOutlet weak var feeContainer: UIView!
    
    private let hashtagsView = ProfileHashtagsContainer.loadFromNib()
    
    private var topGradientLayer: CALayer?
    private var bottomGradientLayer: CALayer?
    
    private var user: User?
   
    private var interactionsEnabled = true
    private var hasAddedCharity = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        topGradientLayer = self.topGradientView.applyGradient(isVertical: true, colorArray: [UIColor.black.withAlphaComponent(0.4), UIColor.clear])
        bottomGradientLayer = self.bottomGradientView.applyGradientStrong(colorArray: [UIColor.clear, UIColor.backgroundColor])
        
        hashtagsContainer.addSubview(hashtagsView)
        hashtagsView.pinToSuperview()
        hashtagsView.populate(items: [])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let topLayer = topGradientLayer,
              let bottomLayer = bottomGradientLayer else {
            
            return
        }
        
        let topFrame = CGRect(x: topLayer.frame.minX, y: topLayer.frame.minY, width: self.bounds.width, height: topLayer.frame.height)
        let bottomFrame = CGRect(x: bottomLayer.frame.minX, y: bottomLayer.frame.minY, width: self.bounds.width, height: bottomLayer.frame.height)
        
        topLayer.frame = topFrame
        bottomLayer.frame = bottomFrame
    }
    
    // MARK: Methods
    
    func populate(user: User, currentUser: User?, totalNumberOfLikes: Int, totalNumberOfInteractions: Int, filter: OtherUserProfileFilter) {
        nameLabel.text = user.name
        profileImageView.setUserImage(url: user.photoURL)
        bioLabel.text = user.bio
        self.user = user
        
        followersLabel.text = "\(user.followers)"
        followingLabel.text = "\(user.following)"
        likesLabel.text = "\(totalNumberOfLikes)"
        interactionsLabel.text = "\(totalNumberOfInteractions)"
        
        interactionsEnabled = user.availableInteractions > 0
        setInteractions()
        
        if let price = user.price {
            moneyIcon.isHidden = false
            priceLabel.text = user.formattedPrice
        } else {
            moneyIcon.isHidden = true
            priceLabel.text = nil
        }
        
//        tipButtonCharity.isHidden = !user.tipsEnabled
//        tipButtonSimple.isHidden = !user.tipsEnabled
//        feeContainer.isHidden = !user.tipsEnabled
        
        
        hashtagsView.populate(items: user.tags)
        
        switch filter {
        case .likes:
            filterLabel.text = "most.popular".localized
            
        case .date:
            filterLabel.text = "latest".localized
        }
        
        if let charity = user.charity, let percentage = user.donationPercentage, percentage > 0 {
            hasAddedCharity = true
            
            charityImageView.setImage(url: charity.imageURL)
            chairtyLabel.text = "\(percentage)% to \(charity.title)"
        } else {
            hasAddedCharity = false
        }
        
        feeContainer.isHidden = hasAddedCharity
        if !user.tipsEnabled {
            feeContainer.isHidden = true
        }
        
        feeWithDontanationContainer.isHidden = !hasAddedCharity
        
        
        
        // Disabled tips
        tipButtonCharity.isHidden = true
        tipButtonSimple.isHidden = true
        feeContainer.isHidden = true
    }
    
    // MARK: Actions
    
    @IBAction func interact(_ sender: Any) {
        delegate?.otherProfileInteract()
    }
    
    @IBAction func followers(_ sender: Any) {
        delegate?.otherProfileFollowers()
    }
    
    @IBAction func following(_ sender: Any) {
        delegate?.otherProfileFollowing()
    }
    
    @IBAction func addTip(_ sender: Any) {
        delegate?.otherProfileAddTip()
    }
    
    @IBAction func filteringChanged(_ sender: Any) {
        delegate?.otherProfileFilterChanged()
    }
    
    // MARK: Private methods
    
    private func setInteractions() {
        if interactionsEnabled {
            let interactions = user?.availableInteractions ?? 0
            interactButton.isHidden = false
            remainingInteractsLabel.text = "\(interactions)"
        } else {
            interactButton.isHidden = true
            remainingInteractsLabel.text = ""
        }
    }
}
