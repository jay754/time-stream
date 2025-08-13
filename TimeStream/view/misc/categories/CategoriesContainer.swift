//
//  CategoriesContainer.swift
//  TimeStream
//
//  
//

import UIKit

protocol CategoriesContainerDelegate: AnyObject {
    func categoriesContainerHasSelected(view: CategoriesContainer, item: Category)
}



class CategoriesContainer: UIView, CategoryItemDelegate {
    
    weak var delegate: CategoriesContainerDelegate?

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!

    var categoriesItems = [CategoryItem]()
    var disableAutoScroll = false
    var selectedCategory: Category = .forYou {
        didSet {
            for category in categoriesItems {
                if category.item == selectedCategory {
                    category.state = .selected
                    if !disableAutoScroll {
                        scrollView.scrollToView(view: category, animated: true)
                    }
                    disableAutoScroll = false
                } else {
                    category.state = .unselected
                }
            }
        }
    }

    override func awakeFromNib() {
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        for category in Category.allCategoriesWithForYourItem {
            let item = CategoryItem.loadFromNib()
            item.populate(category: category)
            item.delegate = self
            
            categoriesItems.append(item)
            stackView.addArrangedSubview(item)
        }
        
        selectedCategory = .forYou
    }
    
    // MARK: Delegate
    
    func categoryItemSelected(view: CategoryItem, item: Category) {
        for view in categoriesItems {
            view.state = .unselected
        }
        
        view.state = .selected
        disableAutoScroll = true
        selectedCategory = item
        delegate?.categoriesContainerHasSelected(view: self, item: item)
    }
}
