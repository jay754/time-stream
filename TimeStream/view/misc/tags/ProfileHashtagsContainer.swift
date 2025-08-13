//
//  HashtagsContainer.swift
//  TimeStream
//
//  Created by appssemble on 22.07.2021.
//

import UIKit

class ProfileHashtagsContainer: UIView {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    private var items = [String]()
    
    override func awakeFromNib() {
        addHeightConstraint(value: 14)
        
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    // MARK: Methods
    
    func populate(items: [String]) {
        self.items = items
        
        stackView.arrangedSubviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        for item in items {
            let view = ProfileHashtagItem.loadFromNib()
            view.populate(item: item)
            
            stackView.addArrangedSubview(view)
        }
    }
}
