//
//  OnboardingViewController.swift
//  TimeStream
//
//  Created by appssemble on 03.07.2021.
//

import UIKit

protocol OnboardingFlowDelegate: BaseViewControllerFlowDelegate {
    func onboardingFinished(vc: OnboardingViewController)
}

class OnboardingViewController: UIViewController, UIScrollViewDelegate {
    
    
    weak var flowDelegate: OnboardingFlowDelegate?
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    private let titles = ["Your questions answered", "Video to video", "Support your community and the planet"]
    private let subtitles = ["Expert videos tailored for you.", "Q&A the TIME way.", "Easier than ever to support your favourite charity."]
    private let imagesNames = ["onboarding-1", "onboarding-2", "onboarding-3"]
    
    private var currentPage: Int {
        get {
            let page = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
            
            return page
        }
    }

    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pageControl.currentPage = 0
        scrollView.delegate = self
        
        for i in 0..<titles.count {
            let item = OnboardingItemView.loadFromNib()
            item.addWidthConstraint(value: UIScreen.main.bounds.width)
            
            item.titleLabel.text = titles[i]
            item.subtitleLabel.text = subtitles[i]
            item.imageView.image = UIImage(named: imagesNames[i])
            
            stackView.addArrangedSubview(item)
        }
    }
    
    // MARK: Scroll view delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = currentPage
    }
    
    // MARK: Actions
    
    @IBAction func next(_ sender: Any) {
        scrollToNextPage()
        
        if currentPage == 2 {
            flowDelegate?.onboardingFinished(vc: self)
        }
    }
    
    @IBAction func finish(_ sender: Any) {
        flowDelegate?.onboardingFinished(vc: self)
    }
    
    // MARK: Private
    
    private func scrollToNextPage() {
        var page = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        page += 1
        
        if page >= 3 {
            return
        }
        
        scrollView.setContentOffset(CGPoint(x: CGFloat(page) * scrollView.bounds.width, y: 0), animated: true)
    }
    
}
