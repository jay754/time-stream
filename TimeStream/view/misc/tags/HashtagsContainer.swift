//
//  HashtagsContainer.swift
//  TimeStream
//
//  
//

import UIKit

protocol HashtagsContainerDelegate: class {
    func hashtagContainerDidSelect(container: HashtagsContainer, category: Category)
}

class HashtagsContainer: UIView, HashtagItemDelegate {
    
    weak var delegate: HashtagsContainerDelegate?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    private var items = [Category]()
    
    override func awakeFromNib() {
        addHeightConstraint(value: 25)
        
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    // MARK: Methods
    
    func populate(items: [Category]) {
        self.items = items
        
        stackView.arrangedSubviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        for item in items {
            let view = HashtagItem.loadFromNib()
            view.populate(item: item)
            view.delegate = self
            
            stackView.addArrangedSubview(view)
        }
    }
    
    // MARK: Delegate
    
    func hashtagItemTapped(view: HashtagItem, category: Category) {
        delegate?.hashtagContainerDidSelect(container: self, category: category)
    }
}
