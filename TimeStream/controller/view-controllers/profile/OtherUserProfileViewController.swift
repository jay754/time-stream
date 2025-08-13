//
//  OtherUserProfileViewController.swift
//  TimeStream
//
//  Created by appssemble on 10.08.2021.
//

import UIKit
import Stripe

protocol OtherUserFlowDelegate: BaseViewControllerFlowDelegate {
    func otherProfileAuthenticateUser(vc: OtherUserProfileViewController, completion: @escaping EmptyClosure)
    func otherProfileGoToFollowers(vc: OtherUserProfileViewController, user: User)
    func otherProfileGoToFollowing(vc: OtherUserProfileViewController, user: User)
    func otherProfileGoVideoDetails(vc: OtherUserProfileViewController, video: Video)
    func otherProfileGoRequestVideo(vc: OtherUserProfileViewController, user: User)
}

enum OtherUserProfileFilter {
    case date
    case likes
}

enum OtherUserProfileType {
    case follow
    case unfollow
}

class OtherUserProfileViewController: BaseViewController, AddTipPopupViewControllerDelegate {
    
    weak var flowDelegate: OtherUserFlowDelegate?
    
    var user: User!
    
    private var totalNumberOfLikes = 0
    private var totalNumberOfInteractions = 0
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topContainerActionView: UIView!
    @IBOutlet weak var followUnfollowButton: UIButton!
    
    struct Constants {
        static let cellIdentifier = "VideoCollectionViewCell"
        static let sectionIdentifier = "OtherProfileCollectionReusableView"
        static let emptyCell = "EmptyMessageCollectionViewCell"
        
        static let collectionViewInterRowsSpacing: CGFloat = 12
        static let collectionViewInterColumnsSpacing: CGFloat = 12
    }
    
    private let userService = UserService()
    private let videoService = VideoService()
    private var paymentHelper: AdyenPaymentHelper!
    private var videos = [Video]()
    private let reportHelper = ReportHelper()
    private let dynamicLinkHelper = DynamicLinkHelper()
    
    private var filter: OtherUserProfileFilter = .likes {
        didSet {
            setFilterType()
        }
    }
    
    private var type: OtherUserProfileType = .follow {
        didSet {
            changeFollowButton()
        }
    }
    
    private var firstLoad = true
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(UINib(nibName: "VideoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: Constants.cellIdentifier)
        collectionView.register(UINib(nibName: "OtherProfileCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.sectionIdentifier)
        collectionView.register(UINib(nibName: "EmptyMessageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: Constants.emptyCell)
        collectionView.contentInsetAdjustmentBehavior = .never
        
        paymentHelper = AdyenPaymentHelper(vc: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        
        loadVideos()
        handleFollowUnfollowButton()
        
    }
    
    // MARK: Actions
    
    @IBAction func dots(_ sender: Any) {
        showMoreAlert()
    }
    @IBAction func share(_ sender: Any) {
        self.dynamicLinkHelper.showShareUserSheet(from: self, user: self.user)
    }
    
    @IBAction func followUnfollow(_ sender: Any) {
        if type == .follow {
            flowDelegate?.otherProfileAuthenticateUser(vc: self, completion: {
                self.follow()
            })
            
        } else {
            flowDelegate?.otherProfileAuthenticateUser(vc: self, completion: {
                self.unfollow()
            })
        }
    }
    
    @IBAction func back(_ sender: Any) {
        flowDelegate?.backButtonPressed(from: self)
    }
    
    // MARK: Scroll view delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Top view handling
        var alpha = scrollView.contentOffset.y / 200
        if alpha > 1 {
            alpha = 1
        }
        
        topContainerActionView.backgroundColor = UIColor.backgroundColor.withAlphaComponent(alpha)
    }
    
    // MARK: Private methods
    
    private func handleFollowUnfollowButton() {
        let currentUser = Context.current.user
        if currentUser?.followsUser(id: user.id) ?? false {
            type = .unfollow
        } else {
            type = .follow
        }
    }
    
    private func changeFollowButton() {
        switch type {
        case .follow:
            //followUnfollowButton.setTitle("Follow", for: .normal)
            followUnfollowButton.isHidden = false
            
        case .unfollow:
            //followUnfollowButton.setTitle("Unfollow", for: .normal)
            followUnfollowButton.isHidden = true
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
                
                self.reloadUser()
            }
        }
    }
    
    private func reloadUser() {
        userService.getUser(id: user.id, currencyCode: Currency.current().rawValue) { (result) in
            switch result {
            case .error:
                self.showGenericError()
                
            case .success(let user):
                self.user = user
                
                self.handleFollowUnfollowButton()
                
                UIView.performWithoutAnimation {
                    self.collectionView.reloadSections(IndexSet(0 ..< 1))
                }
            }
        }
    }
    
    private func loadTotalNumberOfLikes() {
        userService.getTotalNumberOfLikesAndInteractions(userID: user.id) { response in
            switch response {
            case .error:
                self.showGenericError()
                
            case .success(let values):
                self.totalNumberOfLikes = values.likes
                self.totalNumberOfInteractions = values.interactions
                self.reloadUser()
            }
        }
    }
    
    private func loadVideos() {
        if !firstLoad {
            disableLoadingShow = true
        }
        
        firstLoad = false
        loading = true
        videoService.otherUserVideos(userID: user.id, currencyCode: Currency.current().rawValue) { result in
            self.loading = false
            self.disableLoadingShow = false
            
            switch result {
            case .success(let videos):
                self.videos = videos.sorted(by: {$0.createdAt > $1.createdAt})
                self.setFilterType()
                self.loadTotalNumberOfLikes()
                
            case .error:
                self.showGenericError()
            }
        }
    }
    
    private func setFilterType() {
        switch filter {
        case .date:
            videos = videos.sorted(by: {$0.createdAt > $1.createdAt})
        case .likes:
            videos = videos.sorted(by: {$0.views > $1.views})
        }
    
        UIView.performWithoutAnimation {
            self.collectionView.reloadSections(IndexSet(0 ..< 2))
        }
    }
}

extension OtherUserProfileViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }
        
        if videos.count == 0 {
            // No items cell
            return 1
        }
        
        return videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if videos.count == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.emptyCell, for: indexPath) as! EmptyMessageCollectionViewCell
            cell.messageLabel.text = "no.other.profile.videos".localized
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! VideoCollectionViewCell
        
        let video = videos[indexPath.row]
        cell.populate(video: video)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {

        case UICollectionView.elementKindSectionHeader:

            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.sectionIdentifier, for: indexPath) as! OtherProfileCollectionReusableView
            header.delegate = self
            
            let currrentUser = Context.current.user
            header.populate(user: user, currentUser: currrentUser, totalNumberOfLikes: totalNumberOfLikes, totalNumberOfInteractions: totalNumberOfInteractions, filter: filter)
            
            return header
        default:
            assert(false, "Unexpected element kind")
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 1 {
            return CGSize.zero
        }
        
        var height: CGFloat = 705
        if UIDevice.current.screenType == .iPhone6Size {
            height = 664
        }
        
        if !user.tipsEnabled && user.donationPercentage ?? 0 <= 0 {
            height -= 55
        }
        
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
    // MARK: Add tip delegate

    func addTip(vc: AddTipPopupViewController, cents: Int) {
        flowDelegate?.otherProfileAuthenticateUser(vc: self, completion: {
            self.loading = true
            self.paymentHelper.startTipPaymentSheet(creatorID: self.user.id, amount: cents) { status in
                self.loading = false
                print("Tip done")
            }
        })
    }
    
}

extension OtherUserProfileViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row < videos.count else {
            return
        }
        
        let video = videos[indexPath.row]
        flowDelegate?.otherProfileGoVideoDetails(vc: self, video: video)
    }

}

extension OtherUserProfileViewController: UICollectionViewDelegateFlowLayout {
    
    // MARK: Delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if videos.count == 0 {
            return CGSize(width: collectionView.bounds.width, height: 100)
        }
        
        let collectionWidth = Int(((collectionView.bounds.width - (2 * Constants.collectionViewInterRowsSpacing)) / 2))
        let width = CGFloat(collectionWidth) - (0.5 * Constants.collectionViewInterRowsSpacing)
    
        let height = width * 1.46
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
       return Constants.collectionViewInterRowsSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return Constants.collectionViewInterColumnsSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            // Normal insets for collection
        return UIEdgeInsets(top: 0, left: Constants.collectionViewInterColumnsSpacing, bottom: 0, right: Constants.collectionViewInterColumnsSpacing)
    }
}


extension OtherUserProfileViewController: OtherProfileCollectionReusableViewDelegate {
    
    func otherProfileAddTip() {
        flowDelegate?.otherProfileAuthenticateUser(vc: self, completion: {
            AddTipPopupViewController.displayFrom(vc: self, completion: nil, delegate: self)
        })
    }
    
    func otherProfileInteract() {
        flowDelegate?.otherProfileAuthenticateUser(vc: self, completion: {
            self.intentFlow()
        })
    }
    
    func otherProfileFollowers() {
        flowDelegate?.otherProfileAuthenticateUser(vc: self, completion: {
            self.flowDelegate?.otherProfileGoToFollowers(vc: self, user: self.user)
        })
    }
    
    func otherProfileFollowing() {
        flowDelegate?.otherProfileAuthenticateUser(vc: self, completion: {
            self.flowDelegate?.otherProfileGoToFollowing(vc: self, user: self.user)
        })
    }
    
    func otherProfileFilterChanged() {
        switch filter {
        case .likes:
            filter = .date
            
        case .date:
            filter = .likes
        }
    }
    
    // MARK: Private methods
    
    private func unfollow() {
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
    
    private func follow() {
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
    
    private func intentFlow() {
        flowDelegate?.otherProfileGoRequestVideo(vc: self, user: user)
    }
    
    private func showMoreAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "report.user".localized, style: .default , handler:{ (UIAlertAction)in
            self.reportHelper.reportUser(userID: self.user.id, from: self)
        }))
        
        /*alert.addAction(UIAlertAction(title: "share.user".localized, style: .default , handler:{ (UIAlertAction)in
            self.dynamicLinkHelper.showShareUserSheet(from: self, user: self.user)
        }))*/
        
        if (type == .unfollow){
            alert.addAction(UIAlertAction(title: "Unfollow".localized, style: .default , handler:{ (UIAlertAction)in
                self.flowDelegate?.otherProfileAuthenticateUser(vc: self, completion: {
                    self.unfollow()
                })
            }))
        }
        
        
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler:{ (UIAlertAction)in
        }))

        //uncomment for iPad Support
        alert.popoverPresentationController?.sourceView = self.view

        self.present(alert, animated: true, completion: {
        })
    }
}
