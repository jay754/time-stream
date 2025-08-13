//
//  ProfileViewController.swift
//  TimeStream
//
//  Created by appssemble on 03.07.2021.
//

import UIKit

protocol ProfileFlowDelegate: BaseViewControllerFlowDelegate {
    func profileEditProfile(vc: ProfileViewController)
    func profilePaymentDetails(vc: ProfileViewController)
    func profileSettings(vc: ProfileViewController)
    func profileGoToFollowers(vc: ProfileViewController, user: User)
    func profileGoToFollowing(vc: ProfileViewController, user: User)
    func profileGoVideo(vc: ProfileViewController, video: Video)
    func profileGoToActivity(vc: ProfileViewController)
    func profileGoToCharity(vc: ProfileViewController)
}


class ProfileViewController: BaseViewController {
    
    weak var flowDelegate: ProfileFlowDelegate?
    var displayedInNavigation = false
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topActionsContainerView: UIView!
    @IBOutlet weak var backButton: UIButton!
    
    private var header: CurrentProfileCollectionReusableView?
    
    struct Constants {
        static let cellIdentifier = "VideoCollectionViewCell"
        static let sectionIdentifier = "CurrentProfileCollectionReusableView"
        static let emptyCell = "EmptyMessageCollectionViewCell"
        
        static let collectionViewInterRowsSpacing: CGFloat = 12
        static let collectionViewInterColumnsSpacing: CGFloat = 12
    }
    
    private let userService = UserService()
    private let paymentService = BackendPaymentService()
    private let videoService = VideoService()
    private var totalNumberOfLikes = 0
    private var totalNumberOfInteractions = 0
    
    private var allVideos = [Video]()
    private var videos = [Video]()
    private var firstLoad = true
    private var bankAccountSetup: BankAccountSetup?
    private let dynamicLinkHelper = DynamicLinkHelper()
    
    private var adyenHelper: AdyenPaymentHelper!
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)

        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(UINib(nibName: "VideoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: Constants.cellIdentifier)
        collectionView.register(UINib(nibName: "CurrentProfileCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.sectionIdentifier)
        collectionView.register(UINib(nibName: "EmptyMessageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: Constants.emptyCell)
        collectionView.contentInsetAdjustmentBehavior = .never
        
        LocalNotifications.addObserver(item: self, selector: #selector(newVideoAdded), type: .videoUploaded)
        
        backButton.isHidden = !displayedInNavigation
        
        adyenHelper = AdyenPaymentHelper(vc: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        
        reloadAllData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let user = Context.current.user else {
            return
        }
        
        if user.availableInteractions < 1 {
            header?.interactButton.shake()
        }
    }
    
    // MARK: Actions
    
    @objc
    private func newVideoAdded() {
        loadVideos()
    }
    
    @IBAction func back(_ sender: Any) {
        flowDelegate?.backButtonPressed(from: self)
    }
    
    @IBAction func editProfile(_ sender: Any) {
        flowDelegate?.profileEditProfile(vc: self)
    }
    
    @IBAction func settings(_ sender: Any) {
        flowDelegate?.profileSettings(vc: self)
    }
    
    @IBAction func shareProfile(_ sender: Any) {
        showMoreAlert()
    }
    
    // MARK: Scroll view delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Top view handling
        var alpha = scrollView.contentOffset.y / 200
        if alpha > 1 {
            alpha = 1
        }
        
        topActionsContainerView.backgroundColor = UIColor.backgroundColor.withAlphaComponent(alpha)
    }
    
    // MARK: Private methods
    
    private func updateInteractionsCount(count: Int, completion: EmptyClosure?) {
        guard var user = Context.current.user else {
            return
        }
        
        user.availableInteractions = count
        loading = true
        userService.updateUser(user: user, photo: nil) { (result) in
            self.loading = false
            switch result {
            case .error:
                self.showGenericError()
                
            case .success(let user):
                Context.current.user = user
                self.reloadData()
            }
            
            completion?()
        }
    }
    
    private func loadVideos() {
        loading = true
        videoService.currentUserVideos { result in
            self.loading = false
            self.disableLoadingShow = false
            
            switch result {
            case .success(let videos):
                self.allVideos = videos
                self.filterVideos()
                self.loadTotalNumberOfLikes()
                
            case .error:
                self.showGenericError()
            }
        }
    }
    
    private func reloadAllData() {
        if !firstLoad {
            disableLoadingShow = true
        }
        
        firstLoad = false
        loading = true
        userService.getCurrentUser { result in
            self.loading = false
            switch result {
            case .error:
                self.showGenericError()
                self.disableLoadingShow = false
                
            case .success(let user):
                Context.current.user = user
                self.loadVideos()
            }
        }
    }
    
    private func filterVideos() {
        let filtered = allVideos.filter({$0.privateVideo == (header?.type == .privateVideos)})
        self.videos = filtered.sorted(by: {$0.createdAt > $1.createdAt})
    }
    
    private func reloadData() {
        UIView.performWithoutAnimation {
            self.collectionView.reloadSections(IndexSet(0 ..< 2))
        }
    }
    
    private func loadTotalNumberOfLikes() {
        guard let user = Context.current.user else {
            return
        }
        
        userService.getTotalNumberOfLikesAndInteractions(userID: user.id) { response in
            switch response {
            case .error:
                self.showGenericError()
                
            case .success(let values):
                self.totalNumberOfLikes = values.likes
                self.totalNumberOfInteractions = values.interactions
                self.reloadData()
                self.loadBankAccount()
            }
        }
    }
    
    private func loadBankAccount() {
        adyenHelper.hasBankAccountAdded { (result) in
            switch result {
            case .error:
                break
                
            case .success(let hasBank):
                self.bankAccountSetup = hasBank
                self.reloadData()
            }
        }
    }
    
    private func showMoreAlert() {
        /*let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
        guard let user = Context.current.user else {
            return
        }
        
        alert.addAction(UIAlertAction(title: "share.user".localized, style: .default , handler:{ (UIAlertAction)in
            self.dynamicLinkHelper.showShareUserSheet(from: self, user: user)
        }))
        
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler:{ (UIAlertAction)in
        }))

        //uncomment for iPad Support
        alert.popoverPresentationController?.sourceView = self.view

        self.present(alert, animated: true, completion: {
        })*/
        guard let user = Context.current.user else {
            return
        }
        self.dynamicLinkHelper.showShareUserSheet(from: self, user: user)
    }
}


extension ProfileViewController: UICollectionViewDataSource {
    
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
            
            if header?.type == .privateVideos {
                cell.messageLabel.text = "no.profile.private.videos".localized
                
            } else {
                cell.messageLabel.text = "no.profile.videos".localized
            }
            
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
            
            let previousType = header?.type ?? .publicVideos
            header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.sectionIdentifier, for: indexPath) as? CurrentProfileCollectionReusableView
            header?.delegate = self
            
            if let user = Context.current.user {
                header?.populate(user: user, totalNumberOfLikes: totalNumberOfLikes, totalNumberOfInteractions: totalNumberOfInteractions, type: previousType, bankAccount: bankAccountSetup)
            }
            
            return header!
        default:
            assert(false, "Unexpected element kind")
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 0 {
            return CGSize.zero
        }
        
        let height: CGFloat = 769
        
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
}

extension ProfileViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let video = videos[indexPath.row]
        flowDelegate?.profileGoVideo(vc: self, video: video)
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    
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


extension ProfileViewController: CurrentProfileCollectionReusableViewDelegate {
    func profileGoCharity() {
        flowDelegate?.profileGoToCharity(vc: self)
    }
    
    func profileGoBankAccount() {
        adyenHelper.openOnboardingScreen { [weak self] in
            self?.loadBankAccount()
        }
    }
    
    func profileGoInteractions() {
        flowDelegate?.profileGoToActivity(vc: self)
    }
    
    func profileTypeChanged(type: CurrentProfileType) {
        filterVideos()
        reloadData()
    }
    
    func profileGoPaymentMethod() {
        flowDelegate?.profilePaymentDetails(vc: self)
    }
    
    func profileGoFollowers() {
        guard let user = Context.current.user else {
            return
        }
        
        flowDelegate?.profileGoToFollowers(vc: self, user: user)
    }
    
    func profileGoFollowing() {
        guard let user = Context.current.user else {
            return
        }
        
        flowDelegate?.profileGoToFollowing(vc: self, user: user)
    }
    
    func profileInteractPressed(type: InteractionsSettingsType) {
        guard let user = Context.current.user else {
            return
        }

        if user.price == nil {
            // Needs to set a price before doing this
            flowDelegate?.profilePaymentDetails(vc: self)
            showAlert(message: "set.price.message".localized)
            return
        }

        InteractionsSettingsViewController.displayFrom(vc: self, type: type, delegate: self, completion: {})
    }
}

extension ProfileViewController: InteractionsSettingsViewControllerDelegate {
    func interactionsSettingsEnableInteractions(vc: InteractionsSettingsViewController, count: Int) {
        updateInteractionsCount(count: count) {
            vc.close()
        }
    }
    
    func interactionsSettingsDisableInteractions(vc: InteractionsSettingsViewController) {
        updateInteractionsCount(count: 0) {
            vc.close()
        }
    }
    
}
