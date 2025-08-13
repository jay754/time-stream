//
//  ExploreSearchSelector.swift
//  TimeStream
//
//  Created by appssemble on 08.12.2021.
//

import UIKit

enum ExploreSearchSelectorState {
    case content
    case people
    case tags
}

protocol ExploreSearchSelectorDelegate: AnyObject {
    func exploreSearchSelectorPicked(view: ExploreSearchSelector, state: ExploreSearchSelectorState)
}

class ExploreSearchSelector: UIView {
    
    weak var delegate: ExploreSearchSelectorDelegate?

    @IBOutlet weak var tagsButton: UIButton!
    @IBOutlet weak var peopleButton: UIButton!
    @IBOutlet weak var peopleIndicator: UIView!
    @IBOutlet weak var contentButton: UIButton!
    @IBOutlet weak var contentIndicator: UIView!
    @IBOutlet weak var tagsIndicator: UIView!
   
    var state: ExploreSearchSelectorState = .content {
        didSet {
            setState()
        }
    }
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        state = .content
    }
    
    // MARK: Actions
    
    @IBAction func content(_ sender: Any) {
        state = .content
        
        delegate?.exploreSearchSelectorPicked(view: self, state: .content)
    }
    
    @IBAction func people(_ sender: Any) {
        state = .people
        
        delegate?.exploreSearchSelectorPicked(view: self, state: .people)
    }
    
    @IBAction func tags(_ sender: Any) {
        state = .tags
        
        delegate?.exploreSearchSelectorPicked(view: self, state: .tags)
    }
    
    // MARK: Private
    
    private func setState() {
        contentButton.setTitleColor(UIColor.text, for: .normal)
        peopleButton.setTitleColor(UIColor.text, for: .normal)
        tagsButton.setTitleColor(UIColor.text, for: .normal)

        contentIndicator.isHidden = true
        peopleIndicator.isHidden = true
        tagsIndicator.isHidden = true
        
        switch state {
        case .content:
            contentButton.setTitleColor(UIColor.accent, for: .normal)
            contentIndicator.isHidden = false
            
        case .people:
            peopleButton.setTitleColor(UIColor.accent, for: .normal)
            peopleIndicator.isHidden = false
            
        case .tags:
            tagsButton.setTitleColor(UIColor.accent, for: .normal)
            tagsIndicator.isHidden = false
        }
    }
}
