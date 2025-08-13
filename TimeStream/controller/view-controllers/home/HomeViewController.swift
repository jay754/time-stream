//
//  HomeViewController.swift
//  TimeStream
//
//  
//

import UIKit
import Koloda


protocol HomeFlowDelegate: BaseViewControllerFlowDelegate {
    func homeViewGoToVideo(vc: HomeViewController, video: Video)
    func homeViewGoToExploreCategory(vc: HomeViewController, category: Category)
    
    
    func homeViewGoToUser(vc: HomeViewController, user: User)
    func homeViewGoToRequestVideo(vc: HomeViewController, user: User)
}

class HomeViewController: BaseViewController {
    
    weak var flowDelegate: HomeFlowDelegate?
    
    @IBOutlet weak var kolodaView: KolodaView!
    
    private var videoGroups = [HomeVideoGroup]()
    private var videoCards = [HomeCardView]()
    
    private var currentVideoCard: HomeCardView?
    
    private let allCaughtUp = AllCaughtUpView.loadFromNib()
    private let service = HomeService()
    
    private let videoService = VideoService()
    private let userService = UserService()
    private let dynamicLinkHelper = DynamicLinkHelper()
    private let reportHelper = ReportHelper()
    private var adyenPaymentHelper: AdyenPaymentHelper!
    
    private var videoForTip: Video?
    private var disableReloadOnAppear = false
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        adyenPaymentHelper = AdyenPaymentHelper(vc: self)
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        kolodaView.backgroundCardsScalePercent = 0.95
        kolodaView.backgroundCardsTopMargin = 16
        kolodaView.shouldPassthroughTapsWhenNoVisibleCards = true
        kolodaView.backgroundCardFrameAnimationDuration = 0.01
        
        kolodaView.isLoop = false
        
        view.addSubview(allCaughtUp)
        allCaughtUp.pinToSuperview()
        allCaughtUp.isHidden = true
        allCaughtUp.delegate = self
        
        LocalNotifications.addObserver(item: self, selector: #selector(pauseCurrentPlayingVideo), type: .pausePlayingVideo)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadHomeVideos()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !kolodaView.isHidden && !disableReloadOnAppear {
            currentVideoCard?.start()
        }
        
        disableReloadOnAppear = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        currentVideoCard?.stop()
    }
    
    // MARK: Notifications
    
    @objc
    private func pauseCurrentPlayingVideo() {
        currentVideoCard?.stop()
    }
    
    // MARK: Private methods
    
    private func showNoCardsState(data: HomeExplore) {
        kolodaView.isHidden = true
        allCaughtUp.data = data
        allCaughtUp.isHidden = false
        currentVideoCard?.stop()
        currentVideoCard = nil
    }
    
    private func loadExploreVideos() {
        loading = true
        service.exploreVideos { result in
            self.loading = false
            switch result {
            case .success(let value):
                self.showNoCardsState(data: value)
                
            case .error:
                // Or don't show anything
                self.showGenericError()
            }
        }
    }
    
    private func loadHomeVideos() {
        loading = true
        service.homeVideos { result in
            self.loading = false
            
            switch result {
            case .error:
                self.loadExploreVideos()
                
            case .success(let values):
                if values.count == 0 {
                    self.loadExploreVideos()
                    
                    return
                }
                
                self.videoGroups = values
                self.populateHomeVideos()
            }
        }
    }
    
    private func populateHomeVideos() {
        videoCards.removeAll()
        kolodaView.reloadData()
        
        for group in videoGroups {
            let videoCard = HomeCardView.loadFromNib()
            videoCard.populate(group: group)
            videoCard.delegate = self
            
            videoCards.append(videoCard)
        }
        
        kolodaView.reloadData()
        kolodaView.isHidden = false
        allCaughtUp.isHidden = true
    }
    
    private func markCardAsViewed(card: HomeCardView?) {
        guard let card = card else {
            return
        }
        
        let videos = card.videoGroup?.videos ?? []
        videos.forEach { video in
            self.videoService.addView(videoID: video.id) { result in
                // Do nothing
            }
        }
    }
}

extension HomeViewController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        loadExploreVideos()
    }

    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        currentVideoCard?.togglePlay()
    }
    
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return true
    }
    
    func koloda(_ koloda: KolodaView, shouldSwipeCardAt index: Int, in direction: SwipeResultDirection) -> Bool {
        if direction == .up {
            return true
        }
        
        return false
    }
    
    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        return [.up]
    }
    
    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        let videoCard = videoCards[index]
        if videoCard === currentVideoCard {
            // Don't restart the video if the same card is playing
            return
        }
        
        currentVideoCard?.stop()
        
        makeImpactVibration(style: .soft)
        videoCard.start()
        currentVideoCard = videoCard
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        let videoCard = videoCards[index]

        // Mark the previous card as watched
        markCardAsViewed(card: videoCard)
    }
    
    func kolodaSwipeThresholdRatioMargin(_ koloda: KolodaView) -> CGFloat? {
        return 0.2
    }
    
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return false
    }
}


extension HomeViewController: KolodaViewDataSource {

    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return videoCards.count
    }

    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .moderate
    }

    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let view = videoCards[index]
        
        return view
    }

    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return OverlayView(frame: CGRect.zero)
    }
}


extension HomeViewController: HomeCardViewDelegate, AddTipPopupViewControllerDelegate {
    
    func cardViewInteract(view: HomeCardView, video: Video) {
        flowDelegate?.homeViewGoToRequestVideo(vc: self, user: video.postedBy)
    }
    
    func cardViewTip(view: HomeCardView, video: Video) {
        videoForTip = video
        disableReloadOnAppear = true
        currentVideoCard?.stop()
        AddTipPopupViewController.displayFrom(vc: self, completion: nil, delegate: self)
    }
    
    func cardViewLike(view: HomeCardView, video: Video) {
        self.videoService.addLike(videoID: video.id) { result in
            switch result {
            case .error:
                return
                
            case .success(let video):
                self.currentVideoCard?.reloadViewFor(video: video)
            }
        }
    }
    
    func cardViewUnlike(view: HomeCardView, video: Video) {
        self.videoService.deleteLike(videoID: video.id) { result in
            switch result {
            case .error:
                return
                
            case .success(let video):
                self.currentVideoCard?.reloadViewFor(video: video)
            }
        }
    }
    
    func cardViewShare(view: HomeCardView, video: Video) {
        currentVideoCard?.stop()
        dynamicLinkHelper.showShareVideoSheet(from: self, video: video)
    }
    
    func cardViewGoToUser(view: HomeCardView, user: User) {
        flowDelegate?.homeViewGoToUser(vc: self, user: user)
    }
    
    func cardViewDisplayed(view: HomeCardView, video: Video) {
//        videoService.addView(videoID: video.id) { _ in
//            // Do nothing
//        }
    }
    
    func cardViewPlayedEntireVideo(view: HomeCardView, video: Video) {
        videoService.addView(videoID: video.id) { _ in
            // Do nothing
        }
    }
    
    // MARK: Add tip delegate
    
    func addTip(vc: AddTipPopupViewController, cents: Int) {
        guard let video = videoForTip else {
            return
        }
        
        disableReloadOnAppear = true
        self.loading = true
        self.adyenPaymentHelper.startTipPaymentSheet(creatorID: video.postedBy.id, amount: cents) { status in
            self.loading = false
            self.currentVideoCard?.start()
        }
    }
    
    
    // MARK: Add view for previous video
    
    
}

extension HomeViewController: AllCaughtUpViewDelegate {
    func allCaughtUpSelected(video: Video) {
        flowDelegate?.homeViewGoToVideo(vc: self, video: video)
    }
    
    func allCaughtUpSelected(category: Category) {
        flowDelegate?.homeViewGoToExploreCategory(vc: self, category: category)
    }
}
