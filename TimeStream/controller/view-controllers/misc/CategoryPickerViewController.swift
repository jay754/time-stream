//
//  CategoryPickerViewController.swift
//  TimeStream
//
//  Created on 14.12.2021.
//

import UIKit

protocol CategoryPickerFlowDelegate: BaseViewControllerFlowDelegate {
    
}

protocol CategoryPickerActionDelegate: AnyObject {
    func categoryPickerDidPickCategory(vc: CategoryPickerViewController, category: Category)
}

class CategoryPickerViewController: BaseViewController {
    
    weak var flowDelegate: CategoryPickerFlowDelegate?
    weak var actionsDelegate: CategoryPickerActionDelegate?
    
    var otherTitle: String?
    
    var selectedCategory: Category?
    
    private struct Constants {
        static let cellIdentifier = "cellIdentifier"
    }

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    
    private let categories = Category.allCategories
    private let userDefaultsHelper = UserDefaultsHelper()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let otherTitle = otherTitle {
            titleLabel.text = otherTitle
        }
        
        collectionView.register(UINib(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: Constants.cellIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isHidden = true
        
//        title = "categories".localized
        addBackButton(delegate: flowDelegate)
        
        setLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.reloadData()
        collectionContainerHeightConstraint.constant = collectionView.contentSize.height
        
        collectionView.isHidden = false
        collectionView.alpha = 0
        
        view.setNeedsLayout()
        view.layoutIfNeeded()

//        UIView.animate(withDuration: 0.2) {
            self.collectionView.alpha = 1
//        }
        
        let _ = collectionView.observe(\.contentSize, options: [.initial, .new]) { collectionView, change in
            self.collectionContainerHeightConstraint.constant = collectionView.contentSize.height
        }
    }
    
    // MARK: Actions

    
    // MARK: Private
    
    private func setLayout() {
        let estimatedHeight: CGFloat = 50
        let estimatedWidth: CGFloat = 200
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(estimatedWidth),
                                              heightDimension: .estimated(estimatedHeight))

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .fixed(0), top: .fixed(10), trailing: .fixed(10), bottom: .fixed(0))
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(estimatedHeight))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        collectionView.collectionViewLayout = layout
    }
}


extension CategoryPickerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! CategoryCollectionViewCell
        
        let category = categories[indexPath.row]
        let isSelected = selectedCategory == category
        
        cell.setCategory(category: category)
        cell.type = isSelected ? .selected : .unselected
        
        return cell
    }
}


extension CategoryPickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        selectedCategory = category

        collectionView.reloadData()
        
        actionsDelegate?.categoryPickerDidPickCategory(vc: self, category: category)
        flowDelegate?.backButtonPressed(from: self)
    }
}


