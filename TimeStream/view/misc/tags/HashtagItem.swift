//
//  HashtagItem.swift
//  TimeStream
//
//  
//

import UIKit

protocol HashtagItemDelegate: class {
    func hashtagItemTapped(view: HashtagItem, category: Category)
}

class HashtagItem: UIView {
    
    weak var delegate: HashtagItemDelegate?

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var containerView: UIView!

    var category: Category?
    
    // MARK: Methods
    
    func populate(item: Category) {
        category = item
        label.text = item.name
    }
    
    // MARK: Actions
    
    @IBAction func didTap(_ sender: Any) {
        guard let text = label.text, let category = category else {
            return
        }
        
        delegate?.hashtagItemTapped(view: self, category: category)
    }
}
