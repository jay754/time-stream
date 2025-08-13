//
//  CategoryCollectionViewCell.swift
//  TimeStream
//
//  
//

import UIKit


enum CategoryCollectionCellType {
    case unselected
    case selected
}

class CategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var hashtagLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var type = CategoryCollectionCellType.selected {
        didSet {
            changeType()
        }
    }
    
    // MARK: Methods
    
    func setCategory(category: Category) {
        categoryLabel.text = category.name
        
        type = .unselected
    }
    
    // MARK: Private methods
    
    private func changeType() {
        switch type {
        case .selected:
            containerView.backgroundColor = UIColor.accent
            categoryLabel.textColor = .white
            hashtagLabel.textColor = .white
            
        case .unselected:
            containerView.backgroundColor = UIColor.unselectedContainerColor
            categoryLabel.textColor = UIColor.unselectedContainerText
            hashtagLabel.textColor = UIColor.unselectedContainerText
        }
    }

}
