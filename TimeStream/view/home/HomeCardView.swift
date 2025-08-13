//
//  HomeCardView.swift
//  TimeStream
//
//  Created on 16.07.2021.
//

import UIKit

protocol HomeCardViewDelegate: AnyObject {
    func cardViewInteract(view: HomeCardView, video: Video)
    func cardViewTip(view: HomeCardView, video: Video)
    func cardViewLike(view: HomeCardView, video: Video)
    func cardViewUnlike(view: HomeCardView, video: Video)
    func cardViewShare(view: HomeCardView, video: Video)
    
    func cardViewGoToUser(view: HomeCardView, user: User)
    func cardViewDisplayed(view: HomeCardView, video: Video)
    func cardViewPlayedEntireVideo(view: HomeCardView, video: Video)
}

class HomeCardView: UIView, UIScrollViewDelegate {

    weak var delegate: HomeCardViewDelegate?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var tagsContainer: UIView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var actionsContainer: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postedTimeLabel: UILabel!
    
    var isPlaying: Bool {
        get {
            return playingVideoView?.isPlaying ?? false
        }
    }
    
    private let tagsView = VideoTagsView.loadFromNib()
    let actionsView = ActionsView.loadFromNib()
    
    private var videoViews = [VideoView]()
    var videoGroup: HomeVideoGroup?
    
    private var currentPage: Int {
        get {
            let page = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
            
            return page
        }
    }
    
    private var playingVideoView: VideoView?
    private var previousPage: Int = 0
    
    // MARK: Ovewritten
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollView.delegate = self
        
        tagsContainer.addSubview(tagsView)
        tagsView.pinToSuperview()
        
        actionsContainer.addSubview(actionsView)
        actionsView.pinToSuperview()
        actionsView.delegate = self
        
        gradientView.applyGradient(isVertical: true, colorArray: [UIColor.clear, UIColor.black.withAlphaComponent(0.4)])
        
        pageControl.isHidden = true
    }
    
    // MARK: Methods
    
    func populate(group: HomeVideoGroup) {
        videoGroup = group
        addVideos()
        
        userImageView.setImage(url: group.user.photoURL)
        userNameLabel.text = group.user.name
    }
    
    func start() {
        pageControl.isHidden = videoGroup?.videos.count ?? 0 == 1 
        
        if playingVideoView == nil {
            setNewVideoPlaying(page: 0)
            
        } else {
            playingVideoView?.isPlaying = true
        }
    }
    
    func stop() {
        playingVideoView?.isPlaying = false
    }
    
    func togglePlay() {
        if isPlaying {
            stop()
        } else {
            start()
        }
    }
    
    func reloadViewFor(video: Video) {
        guard let videoGroup = videoGroup else {
            return
        }
        
        // Replace the video
        var newVideos = [Video]()
        for v in videoGroup.videos {
            if v.id == video.id {
                newVideos.append(video)
            } else {
                newVideos.append(v)
            }
        }
        
        // Replace the video group
        self.videoGroup = HomeVideoGroup(user: videoGroup.user, videos: newVideos)
    
        if let current = getCurrentVideo(), video.id == current.id {
            setCurrentVideo(video: video)
        }
    }
    
    // MARK: Scroll view delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = currentPage
        if previousPage != currentPage {
            setNewVideoPlaying(page: currentPage)
        }
    }
    
    // MARK: Actions
    
    @IBAction func goToUser(_ sender: Any) {
        guard let videoGroup = videoGroup else {
            return
        }

        delegate?.cardViewGoToUser(view: self, user: videoGroup.user)
    }
    
    // MARK: Private methods
    
    private func setNewVideoPlaying(page: Int) {
        let newVideoView = videoViews[page]
        playingVideoView?.isPlaying = false
        
        playingVideoView?.delegate = nil
        newVideoView.delegate = self
        
        playingVideoView = newVideoView
        playingVideoView?.isPlaying = true
        previousPage = page
        
        if let video = videoGroup?.videos[page] {
            setCurrentVideo(video: video)
        }
    }
    
    private func setCurrentVideo(video: Video) {
        tagsView.setTags(video: video)
        actionsView.populate(video: video)
        postedTimeLabel.text = video.createdAt.prettyFormattedSmall()
        
        delegate?.cardViewDisplayed(view: self, video: video)
    }
    
    private func addVideos() {
        videoViews.removeAll()
        stackView.arrangedSubviews.forEach({$0.removeFromSuperview()})
        
        guard let videoGroup = videoGroup else {
            return
        }
        
        for video in videoGroup.videos {
            let videoView = VideoView.loadFromNib()
            videoView.setMedia(url: video.url)
            videoView.isPlaying = false

            let width = UIScreen.main.bounds.width
            videoView.addWidthConstraint(value: width)
            stackView.addArrangedSubview(videoView)
            
            videoViews.append(videoView)
        }
        
        pageControl.numberOfPages = videoGroup.videos.count
        pageControl.currentPage = 0
        pageControl.isHidden = true
    }
}

extension HomeCardView: VideoViewDelegate {
    func videoViewHasLoopedVideo(view: VideoView, videoURL: URL) {
        guard let group = videoGroup, let video = group.videos.first(where: {$0.url.absoluteURL == videoURL.absoluteURL}) else {
            return
        }
        
        // Has looped
        delegate?.cardViewPlayedEntireVideo(view: self, video: video)
    }
}


extension HomeCardView: ActionsViewDelegate {
    func actionsDelegateUnlike(view: ActionsView) {
        guard let video = getCurrentVideo() else {
            return
        }
        
        delegate?.cardViewUnlike(view: self, video: video)
    }
    
    func actionsDelegateInteract(view: ActionsView) {
        guard let video = getCurrentVideo() else {
            return
        }
        
        delegate?.cardViewInteract(view: self, video: video)
    }
    
    func actionsDelegateTip(view: ActionsView) {
        guard let video = getCurrentVideo() else {
            return
        }
        
        delegate?.cardViewTip(view: self, video: video)
    }
    
    func actionsDelegateLike(view: ActionsView) {
        guard let video = getCurrentVideo() else {
            return
        }
        
        delegate?.cardViewLike(view: self, video: video)
    }
    
    func actionsDelegateShare(view: ActionsView) {
        guard let video = getCurrentVideo() else {
            return
        }
        
        delegate?.cardViewShare(view: self, video: video)
    }

    // MARK: Private methods
    
    private func getCurrentVideo() -> Video? {
        guard let group = videoGroup else {
            return nil
        }

        return group.videos[currentPage]
    }
}
