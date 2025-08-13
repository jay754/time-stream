//
//  ExplorePageHeaderView.swift
//  TimeStream
//
//  Created by appssemble on 07.12.2021.
//

import UIKit

protocol ExplorePageHeaderViewDelegate: AnyObject {
    func exploreHeaderViewAll(view: ExplorePageHeaderView, category: Category)
}

class ExplorePageHeaderView: UIView {

    weak var delegate: ExplorePageHeaderViewDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seeAllContainer: UIView!
    
    private var category: Category?
    
    func setTitle(title: String, seeAll: Bool, category: Category?) {
        self.category = category
        titleLabel.text = title
        seeAllContainer.isHidden = !seeAll
    }
    
    // MARK: Actions
    
    @IBAction func seeAllTapped(_ sender: Any) {
        guard let category = category else {
            return
        }
        
        delegate?.exploreHeaderViewAll(view: self, category: category)
    }
}
