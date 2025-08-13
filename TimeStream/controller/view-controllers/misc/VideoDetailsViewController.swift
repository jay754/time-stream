//
//  VideoDetailsViewController.swift
//  TimeStream
//
//  Created by appssemble on 05.10.2021.
//

import UIKit
import AVFoundation

protocol VideoDetailsFlowDelegate: BaseViewControllerFlowDelegate {
    func videoDetailsGoToUser(vc: VideoDetailsViewController, user: User)
    func videoDetailsGoToVideo(vc: VideoDetailsViewController, video: Video)
    func videoDetailsGoToRequestVideo(vc: VideoDetailsViewController, user: User)
    func videoDetailsAuthenticateAndDo(vc: VideoDetailsViewController, completion: @escaping SimpleAuthClosure)
}

class VideoDetailsViewController: BaseViewController, UIScrollViewDelegate {
    
    weak var flowDelegate: VideoDetailsFlowDelegate?
    
    var video: Video!
    
    private struct Constants {
        static let cellIdentifier = "RelatedVideoCollectionViewCell"
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var actionsContainer: UIView!
    
    @IBOutlet weak var charityContainer: UIView!
    @IBOutlet weak var charityLogo: UIImageView!
    @IBOutlet weak var charityPercentageLabel: UILabel!
    @IBOutlet weak var charityNameLabel: UILabel!
    
    @IBOutlet weak var tagsContainer: UIView!
    
    @IBOutlet weak var bottomGradientView: UIView!
    @IBOutlet weak var topGradientView: UIView!
    
    private let videoView = VideoView.loadFromNib()
    
    private let tagsView = VideoTagsView.loadFromNib()
    private let actionsView = ActionsView.loadFromNib()
    
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var postedLabel: UILabel!
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var priceContainer: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    
    @IBOutlet weak var videoDescriptionLabel: UILabel!
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var topActionsContainer: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!

    private var relatedVideos = [Video]()
    
    private let videoService = VideoService()
    private let userService = UserService()
    private let dynamicLinkHelper = DynamicLinkHelper()
    private let reportHelper = ReportHelper()
    private var adyenPaymentHelper: AdyenPaymentHelper!
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Check if this is still needed
        seeAllButton.isHidden = true
        
        adyenPaymentHelper = AdyenPaymentHelper(vc: self)
        
        self.configureUI()
        self.reloadUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        loadRelatedVideos()
        
        DispatchQueue.main.async {
            self.videoView.isPlaying = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        addView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        videoView.isPlaying = false
    }
    
    // MARK: Scroll view delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === self.scrollView else {
            return
        }
        
        // Top view handling
        var alpha = scrollView.contentOffset.y / 200
        if alpha > 1 {
            alpha = 1
        }
        
        topActionsContainer.backgroundColor = UIColor.darkBackgroundColor.withAlphaComponent(alpha)
    }
    
    // MARK: Actions
    
    @IBAction func back(_ sender: Any) {
        flowDelegate?.backButtonPressed(from: self)
    }
    
    @IBAction func more(_ sender: Any) {
        showOptionSheet()
    }
    
    @IBAction func seeAll(_ sender: Any) {
        print("see all")
    }
    
    @IBAction func follow(_ sender: Any) {
        flowDelegate?.videoDetailsAuthenticateAndDo(vc: self, completion: { wasPrevioulyAuthenticated in
            guard let currentUser = Context.current.user else {
                return
            }
            
            if currentUser.followsUser(id: self.video.postedBy.id) {
                self.unfollow(user: self.video.postedBy)
            } else {
                self.follow(user: self.video.postedBy)
            }
        })
    }
    
    @IBAction func videoTap(_ sender: Any) {
        videoView.isPlaying = !videoView.isPlaying
    }
    
    @IBAction func charityTap(_ sender: Any) {
        flowDelegate?.videoDetailsGoToUser(vc: self, user: video.postedBy)
    }
    
    @IBAction func userTap(_ sender: Any) {
        flowDelegate?.videoDetailsGoToUser(vc: self, user: video.postedBy)
    }
    
    // MARK: Private methods
    
    private func unfollow(user: User) {
        loading = true
        userService.unfollowUser(user: user) { (result) in
            self.loading = false
            
            switch result {
            case .error:
                self.showGenericError()
                
            case .success:
                self.reloadCurrentUser()
            }
        }
    }
    
    private func follow(user: User) {
        loading = true
        userService.followUser(user: user) { (result) in
            self.loading = false
            
            switch result {
            case .error:
                self.showGenericError()
                
            case .success:
                self.reloadCurrentUser()
            }
        }
    }
    
    private func reloadCurrentUser() {
        loading = true
        userService.getCurrentUser { (result) in
            self.loading = false
            switch result {
            case .error:
                self.showGenericError()
                
            case .success(let user):
                Context.current.user = user
                
                self.reloadUI()
            }
        }
    }
    
    private func configureFollowButton() {
        if Context.current.user?.id == video.postedBy.id {
            followButton.isHidden = true
            return
        }
        
        guard let currentUser = Context.current.user else {
            followButton.backgroundColor = .accent
            followButton.setTitle("follow".localized, for: .normal)
            
            return
        }

        if currentUser.followsUser(id: video.postedBy.id) {
            // Following
            followButton.backgroundColor = .unselectedContainerText
            followButton.setTitle("unfollow".localized, for: .normal)
            
        } else {
            // Follow
            followButton.backgroundColor = .accent
            followButton.setTitle("follow".localized, for: .normal)
        }
    }
    
    private func reloadUI() {
        configureFollowButton()
        populateUI()
    }
    
    private func configureUI() {
        scrollView.contentInsetAdjustmentBehavior = .never

        topGradientView.applyGradient(isVertical: true, colorArray: [UIColor.black.withAlphaComponent(0.4), UIColor.clear])
        bottomGradientView.applyGradient(isVertical: true, colorArray: [UIColor.clear, UIColor.black.withAlphaComponent(0.4)])

        videoContainerView.addSubview(videoView)
        videoView.pinToSuperview()

        videoView.setMedia(url: video.url)

        actionsContainer.addSubview(actionsView)
        actionsView.pinToSuperview()
        actionsView.delegate = self

        tagsContainer.addSubview(tagsView)
        tagsView.pinToSuperview()

        seeAllButton.semanticContentAttribute = .forceRightToLeft
        scrollView.delegate = self

        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.register(UINib(nibName: "RelatedVideoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: Constants.cellIdentifier)
        collectionView.dataSource = self
        collectionView.reloadData()
        collectionView.delegate = self
    }
    
    private func populateUI() {
        userImageView.setUserImage(url: video.postedBy.photoURL)
        nameLabel.text = video.postedBy.name
        videoDescriptionLabel.text = video.description
        priceLabel.text = video.postedBy.formattedPrice
        
        DispatchQueue.main.async {
            self.timeLabel.text = AVAsset.durationForAsset(url: self.video.url)
        }

        postedLabel.text = video.createdAt.prettyFormatted()
        tagsView.setTags(video: video)
        
        viewsLabel.text = video.numberOfViews
        
        if let charity = video.postedBy.charity,
           let percentage = video.postedBy.donationPercentage,
           percentage > 0 {
            charityLogo.setImage(url: charity.imageURL)
            charityNameLabel.text = charity.title
            charityPercentageLabel.text = "\(percentage)% to"
            charityContainer.isHidden = false
        } else {
            charityContainer.isHidden = true
        }
        
        actionsView.populate(video: video)
    }
    
    private func loadRelatedVideos() {
//        loading = true
        videoService.getRelatedVideos(videoID: video.id, currencyCode: Currency.current().rawValue) { result in
//            self.loading = false
            
            switch result {
            case .error:
                self.showGenericError()
                
            case .success(let values):
                self.relatedVideos = values
                
                UIView.performWithoutAnimation {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    private func addView() {
        videoService.addView(videoID: video.id) { result in
            // Do nothing
            
            switch result {
            case .success(let video):
                self.video = video
                self.populateUI()
                
            case .error:
               break
            }
        }
    }
    
    private func showOptionSheet() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if video.postedBy.id == Context.current.user?.id {
            alert.addAction(UIAlertAction(title: "delete".localized, style: .destructive , handler:{ (UIAlertAction)in
                self.deleteVideo()
            }))
        } else {
            alert.addAction(UIAlertAction(title: "report".localized, style: .default , handler:{ (UIAlertAction)in
                self.reportHelper.reportVideo(videoID: self.video.id, from: self)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel , handler:{ (UIAlertAction)in
        }))
        
        //uncomment for iPad Support
        alert.popoverPresentationController?.sourceView = self.view
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    private func deleteVideo() {
        loading = true
        videoService.deleteVideo(video: video) { result in
            self.loading = false
            
            switch result {
            case .success:
                self.flowDelegate?.backButtonPressed(from: self)
                
            case .error:
                self.showGenericError()
            }
        }
    }
    
}

extension VideoDetailsViewController: ActionsViewDelegate, AddTipPopupViewControllerDelegate {
    func actionsDelegateUnlike(view: ActionsView) {
        flowDelegate?.videoDetailsAuthenticateAndDo(vc: self, completion: { wasPrevioulyAuthenticated in
            self.videoService.deleteLike(videoID: self.video.id) { result in
                switch result {
                case .error:
                    return
                    
                case .success(let video):
                    self.video = video
                    self.reloadUI()
                }
            }
        })
    }
    
    func actionsDelegateInteract(view: ActionsView) {
        flowDelegate?.videoDetailsAuthenticateAndDo(vc: self, completion: { wasPrevioulyAuthenticated in
            self.flowDelegate?.videoDetailsGoToRequestVideo(vc: self, user: self.video.postedBy)
        })
    }
    
    func actionsDelegateTip(view: ActionsView) {
        flowDelegate?.videoDetailsAuthenticateAndDo(vc: self, completion: { wasPrevioulyAuthenticated in
            AddTipPopupViewController.displayFrom(vc: self, completion: nil, delegate: self)
        })
    }
    
    func actionsDelegateLike(view: ActionsView) {
        flowDelegate?.videoDetailsAuthenticateAndDo(vc: self, completion: { wasPrevioulyAuthenticated in
            self.videoService.addLike(videoID: self.video.id) { result in
                switch result {
                case .error:
                    return
                    
                case .success(let video):
                    self.video = video
                    self.reloadUI()
                }
            }
        })
    }
    
    func actionsDelegateShare(view: ActionsView) {
        dynamicLinkHelper.showShareVideoSheet(from: self, video: self.video)
    }
    
    // MARK: Add tip delegate

    func addTip(vc: AddTipPopupViewController, cents: Int) {
        flowDelegate?.videoDetailsAuthenticateAndDo(vc: self, completion: { wasPrevioulyAuthenticated in
            self.loading = true
            self.adyenPaymentHelper.startTipPaymentSheet(creatorID: self.video.postedBy.id, amount: cents) { status in
                self.loading = false
                print("Tip done")
            }
        })
    }
}


extension VideoDetailsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if relatedVideos.count == 0 {
            collectionView.setMessage("no.related.videos".localized)
        } else {
            collectionView.clearBackground()
        }
        
        
        return relatedVideos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! RelatedVideoCollectionViewCell
        
        let video = relatedVideos[indexPath.row]
        cell.populate(video: video)
        
        return cell
    }
    
}

extension VideoDetailsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let video = relatedVideos[indexPath.row]
        flowDelegate?.videoDetailsGoToVideo(vc: self, video: video)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 153, height: 272)
    }
    
}
