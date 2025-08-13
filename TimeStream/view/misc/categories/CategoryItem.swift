//
//  CategoryItem.swift
//  TimeStream
//
//

import UIKit

enum CategoryItemState {
    case selected
    case unselected
}

protocol CategoryItemDelegate: AnyObject {
    func categoryItemSelected(view: CategoryItem, item: Category)
}

class CategoryItem: UIView {
    
    weak var delegate: CategoryItemDelegate?

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var label: UILabel!
    
    var state: CategoryItemState = .unselected {
        didSet {
            setState()
        }
    }
    
    var item: Category!
    
    // MARK: Methods
    
    func populate(category: Category) {
        item = category
        
        label.text = category.name
    }
  
    // MARK: Actions
    
    @IBAction func tapped(_ sender: Any) {
        delegate?.categoryItemSelected(view: self, item: item)
    }
    
    // MARK: Private methods
    
    private func setState() {
        switch state {
        case .unselected:
            container.backgroundColor = UIColor.tertiaryAccentColor
            label.textColor = UIColor.accent
            
        case .selected:
            container.backgroundColor = UIColor.accent
            label.textColor = UIColor.white
        }
    }
    
}
