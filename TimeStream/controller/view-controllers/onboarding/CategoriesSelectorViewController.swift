//
//  CategoriesSelectorViewController.swift
//  TimeStream
//
//  Created on 15.07.2021.
//

import UIKit

protocol CategoriesSelectorFlowDelegate: BaseViewControllerFlowDelegate {
    func categoriesWereSelected(vc: CategoriesSelectorViewController)
}


class CategoriesSelectorViewController: BaseViewController {
    
    weak var flowDelegate: CategoriesSelectorFlowDelegate?
    
    private struct Constants {
        static let cellIdentifier = "cellIdentifier"
    }

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var getStartedButton: ConfirmationButton!
    @IBOutlet weak var collectionContainerHeightConstraint: NSLayoutConstraint!
    
    private var selectedCategories = [Category]()
    private let categories = Category.allCategories
    
    private let userDefaultsHelper = UserDefaultsHelper()
    private let userService = UserService()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enableIfNeeded()
        
        collectionView.register(UINib(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: Constants.cellIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isHidden = true
        getStartedButton.isHidden = true
        
        setLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.reloadData()
        collectionContainerHeightConstraint.constant = collectionView.contentSize.height
        
        collectionView.isHidden = false
        getStartedButton.isHidden = false
        
        collectionView.alpha = 0
        getStartedButton.alpha = 0
        
        view.setNeedsLayout()
        view.layoutIfNeeded()

        UIView.animate(withDuration: 0.5) {
            self.collectionView.alpha = 1
            self.getStartedButton.set(active: false)
        }
        
        let _ = collectionView.observe(\.contentSize, options: [.initial, .new]) { collectionView, change in
            self.collectionContainerHeightConstraint.constant = collectionView.contentSize.height
        }
    }
    
    // MARK: Actions

    @IBAction func getStartedTapped(_ sender: Any) {
        guard selectedCategories.count >= 3 else {
            return
        }
        
        let categs = selectedCategories.map({$0.rawValue})
        userDefaultsHelper.set(array: categs, key: .selectedCategories)
        
        flowDelegate?.categoriesWereSelected(vc: self)
        
        handleUserIfNeeded(categories: selectedCategories)
    }
    
    // MARK: Private
    
    private func handleUserIfNeeded(categories: [Category]) {
        guard let user = Context.current.user else {
            self.flowDelegate?.categoriesWereSelected(vc: self)
            return
        }
        
        var newUser = user
        newUser.currency = Currency.current()
        newUser.fcmToken = PushNotificationsManager.instance.pushNotificationsToken
        newUser.categoriesOfInterest = categories
        
        loading = true
        userService.updateUserPreferences(user: newUser) { (result) in
            self.loading = false
            
            switch result {
            case .error:
                self.showGenericError()
                
            case .success(let user):
                Context.current.user = user
                self.flowDelegate?.categoriesWereSelected(vc: self)
            }
        }
    }
    
    private func enableIfNeeded() {
        getStartedButton.set(active: selectedCategories.count >= 3)
    }
    
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


extension CategoriesSelectorViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! CategoryCollectionViewCell
        
        let category = categories[indexPath.row]
        let isSelected = selectedCategories.contains(category)
        
        cell.setCategory(category: category)
        cell.type = isSelected ? .selected : .unselected
        
        return cell
    }
}


extension CategoriesSelectorViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryCollectionViewCell

        let category = categories[indexPath.row]
        if selectedCategories.contains(category) {
            selectedCategories.removeAll(where: {$0 == category})
        } else {
            selectedCategories.append(category)
        }

        let isSelected = selectedCategories.contains(category)

        cell.type = isSelected ? .selected : .unselected
        enableIfNeeded()
    }
}

