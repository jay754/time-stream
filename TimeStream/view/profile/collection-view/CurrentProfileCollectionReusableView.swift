//
//  CurrentProfileCollectionReusableView.swift
//  TimeStream
//
//  Created by appssemble on 13.08.2021.
//

import UIKit

protocol CurrentProfileCollectionReusableViewDelegate: class {
    func profileTypeChanged(type: CurrentProfileType)
    func profileGoPaymentMethod()
    func profileGoCharity()
    func profileGoBankAccount()
    func profileGoFollowers()
    func profileGoFollowing()
    func profileGoInteractions()
    func profileInteractPressed(type: InteractionsSettingsType)
}

enum CurrentProfileType {
    case publicVideos
    case privateVideos
}

class CurrentProfileCollectionReusableView: UICollectionReusableView, CurrentUserProfileActionsDelegate {
    
    weak var delegate: CurrentProfileCollectionReusableViewDelegate?

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
    @IBOutlet weak var privateButton: UIButton!
    @IBOutlet weak var publicButton: UIButton!
    @IBOutlet weak var interactButton: UIButton!
    
    @IBOutlet weak var upperHashtagSpaceContainer: UIView!
    @IBOutlet weak var lowerHashtagSpaceContainer: UIView!
    @IBOutlet weak var moneyIcon: UIImageView!
    
    private let currentUserActionsView = CurrentUserProfileActionsView.loadFromNib()
    @IBOutlet weak var setupActionsContainer: UIView!
    
    private var user: User?
    
    var type: CurrentProfileType = .publicVideos {
        didSet {
            changeType()
        }
    }
    
    private let hashtagsView = ProfileHashtagsContainer.loadFromNib()
    
    private var topGradientLayer: CALayer?
    private var bottomGradientLayer: CALayer?
    
    private var interactionsEnabled = true
    private var hasAddedFee = false
    private var hasAddedFeeDonations = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        topGradientLayer = self.topGradientView.applyGradient(isVertical: true, colorArray: [UIColor.black.withAlphaComponent(0.4), UIColor.clear])
        bottomGradientLayer = self.bottomGradientView.applyGradientStrong(colorArray: [UIColor.clear, UIColor.backgroundColor])
        
        hashtagsContainer.addSubview(hashtagsView)
        hashtagsView.pinToSuperview()
        hashtagsView.populate(items: [])
        
        type = .publicVideos
        
        setupActionsContainer.addSubview(currentUserActionsView)
        currentUserActionsView.pinToSuperview()
        currentUserActionsView.delegate = self
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
    
    // MARK: Actions delegate
    
    func currentUserActionsSetPrice(view: CurrentUserProfileActionsView) {
        delegate?.profileGoPaymentMethod()
    }
    
    func currentUserActionsSetCharity(view: CurrentUserProfileActionsView) {
        delegate?.profileGoCharity()
    }
    
    func currentUserActionsSetAvailability(view: CurrentUserProfileActionsView) {
        if interactionsEnabled {
            delegate?.profileInteractPressed(type: .disable)
        } else {
            delegate?.profileInteractPressed(type: .enable)
        }
    }
    
    func currentUserActionsSetBankAccount(view: CurrentUserProfileActionsView) {
        delegate?.profileGoBankAccount()
    }
    
    // MARK: Methods
    
    func populate(user: User, totalNumberOfLikes: Int, totalNumberOfInteractions: Int, type: CurrentProfileType, bankAccount: BankAccountSetup?) {
        nameLabel.text = user.name
        profileImageView.setUserImage(url: user.photoURL)
        bioLabel.text = user.bio
        self.user = user

        interactionsEnabled = user.availableInteractions > 0
        setInteractions()
        
        followersLabel.text = "\(user.followers)"
        followingLabel.text = "\(user.following)"
        likesLabel.text = "\(totalNumberOfLikes)"
        interactionsLabel.text = "\(totalNumberOfInteractions)"
        
        if let _ = user.price {
            moneyIcon.isHidden = false
            priceLabel.text = user.formattedPrice
            hasAddedFee = true
        } else {
            moneyIcon.isHidden = true
            priceLabel.text = nil
            hasAddedFee = false
        }
   
        hasAddedFeeDonations = user.donationsAllowed
        hashtagsView.populate(items: user.tags)
        
        let shouldHideHashtags = user.tags.count == 0
        hashtagsContainer.isHidden = shouldHideHashtags
        lowerHashtagSpaceContainer.isHidden = shouldHideHashtags
        
        self.type = type
        
        currentUserActionsView.populate(user: user, bankAccount: bankAccount)
    }
    
    // MARK: Actions
    
    @IBAction func interact(_ sender: Any) {
        if interactionsEnabled {
            delegate?.profileInteractPressed(type: .disable)
        } else {
            delegate?.profileInteractPressed(type: .enable)
        }
    }
    
    @IBAction func followers(_ sender: Any) {
        delegate?.profileGoFollowers()
    }
    
    @IBAction func following(_ sender: Any) {
        delegate?.profileGoFollowing()
    }
    
    @IBAction func publicVideo(_ sender: Any) {
        type = .publicVideos
        delegate?.profileTypeChanged(type: type)
    }
    
    @IBAction func privateVideos(_ sender: Any) {
        type = .privateVideos
        delegate?.profileTypeChanged(type: type)
    }
    
    @IBAction func interactions(_ sender: Any) {
        delegate?.profileGoInteractions()
    }
    
    private func changeType() {
        switch type {
        case .publicVideos:
            publicButton.setImage(UIImage(named: "video-public-selected"), for: .normal)
            privateButton.setImage(UIImage(named: "video-private-unselected"), for: .normal)
            
        case .privateVideos:
            publicButton.setImage(UIImage(named: "video-public-unselected"), for: .normal)
            privateButton.setImage(UIImage(named: "video-private-selected"), for: .normal)
        }
    }
    
    private func setInteractions() {
        if interactionsEnabled {
            let interactions = user?.availableInteractions ?? 0
            interactButton.setImage(UIImage(named: "interact-button"), for: .normal)
            remainingInteractsLabel.text = "\(interactions)"
        } else {
            interactButton.setImage(UIImage(named: "interact-button-disabled"), for: .normal)
            remainingInteractsLabel.text = ""
        }
    }
    
}
