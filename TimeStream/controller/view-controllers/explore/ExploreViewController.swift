//
//  ExploreViewController.swift
//  TimeStream
//
//  Created on 03.07.2021.
//

import UIKit
import KafkaRefresh

protocol ExploreFlowDelegate: BaseViewControllerFlowDelegate {
    func exploreGoToUser(vc: ExploreViewController, user: User)
    func exploreGoToVideo(vc: ExploreViewController, video: Video)
    func exploreGoToCategory(vc: ExploreViewController, category: Category)
    func exploreGoToCategoriesSelection(vc: ExploreViewController)
    
    func exploreHandleLoginAndDoAction(vc: ExploreViewController, completion: @escaping SimpleAuthClosure)
}

class ExploreViewController: BaseViewController, CategoriesContainerDelegate, ExploreSearchSelectorDelegate, UITextFieldDelegate, ExploreActionsDelegate {
    
    weak var flowDelegate: ExploreFlowDelegate?
    
    var selectedCategory: Category = .forYou
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoriesContainerView: UIView!
    @IBOutlet weak var searchSelectorContainer: UIView!
    @IBOutlet weak var filterButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var categoriesOuterContainer: UIView!
    private let categoriesContainer = CategoriesContainer.loadFromNib()
    private let searchSelector = ExploreSearchSelector.loadFromNib()
    
    private var forYouDatasourceDelegate: ExploreForYouDatasourceDelegate!
    private var categoryDatasourceDelegate: ExploreCategoryDatasourceDelegate!
    private var searchVideosContentDatasourceDelegate: ExploreSearchVideosContentDatasourceDelegate!
    private var searchVideosTagsDatasourceDelegate: ExploreSearchVideosTagsDatasourceDelegate!
    private var usersDatasourceDelegate: ExploreUserSearchDatasourceDelegate!
    
    private var searchState: ExploreSearchSelectorState = .content
    private let userService = UserService()
    private var firstLoad = true
    private var isSearchState = false
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        categoriesContainerView.addSubview(categoriesContainer)
        categoriesContainer.pinToSuperview()
        categoriesContainer.delegate = self
        
        searchSelectorContainer.addSubview(searchSelector)
        searchSelector.pinToSuperview()
        searchSelector.delegate = self
        
        forYouDatasourceDelegate = ExploreForYouDatasourceDelegate(tableView: tableView)
        forYouDatasourceDelegate.actionsDelegate = self
        
        categoryDatasourceDelegate = ExploreCategoryDatasourceDelegate(collectionView: collectionView)
        categoryDatasourceDelegate.actionsDelegate = self
        
        usersDatasourceDelegate = ExploreUserSearchDatasourceDelegate(tableView: tableView)
        usersDatasourceDelegate.actionsDelegate = self
        
        searchVideosContentDatasourceDelegate = ExploreSearchVideosContentDatasourceDelegate(collectionView: collectionView)
        searchVideosContentDatasourceDelegate.actionsDelegate = self
        
        searchVideosTagsDatasourceDelegate = ExploreSearchVideosTagsDatasourceDelegate(collectionView: collectionView)
        searchVideosTagsDatasourceDelegate.actionsDelegate = self
        
        setCurrentState()
        
        searchField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        searchField.delegate = self
        
        LocalNotifications.addObserver(item: self, selector: #selector(willMoveToExplorePage), type: .willMoveToExplorePage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        
        if !isSearchState {
//            setCurrentState()
            reloadDataSources()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if selectedCategory != .forYou && firstLoad {
            categoriesContainer.selectedCategory = selectedCategory
        }

        firstLoad = false
    }
    
    // MARK: Category delegate
    
    func categoriesContainerHasSelected(view: CategoriesContainer, item: Category) {
        selectedCategory = item
        setCurrentState()
    }
    
    // MARK: Search selector delegate
    
    func exploreSearchSelectorPicked(view: ExploreSearchSelector, state: ExploreSearchSelectorState) {
        searchState = state
        setCurrentState()
    }
    
    // Search text field
    
    @objc
    func textFieldChanged() {
        setCurrentState()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setSearchingState()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.count == 0 && !isSearchState {
            setCurrentState()
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = nil
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    // MARK: Actions
    
    @IBAction func changeInterests(_ sender: Any) {
        flowDelegate?.exploreGoToCategoriesSelection(vc: self)
    }
    
    @IBAction func cancelSearch(_ sender: Any) {
        isSearchState = false
        searchField.text = nil
        clearSearch()
        view.endEditing(true)
        setCurrentState()
    }
    
    // MARK: Private methods
    
    @objc
    func willMoveToExplorePage() {
        setCurrentState()
    }
    
    func setCurrentState() {
        if let text = searchField.text,
           text.count > 0 {
            setSearchingState()
            
            return
        }
        
        if searchField.isEditing ||
            isSearchState == true {
            setSearchingState()
            
            return
        }

        searchSelectorContainer.isHidden = true
        categoriesOuterContainer.isHidden = false
        filterButtonWidthConstraint.constant = 48
        cancelButton.isHidden = true
        isSearchState = false
        
        switch selectedCategory {
        case .forYou:
            // Set normal feed
            setNormalState()
            
        default:
            // Set selected category
            setTagSelected()
        }
    }
    
    func setNormalState() {
        collectionView.isHidden = true
        tableView.isHidden = false
        
        forYouDatasourceDelegate.populate(categories: Context.current.categories)
        forYouDatasourceDelegate.loadData()
    }
    
    func setTagSelected() {
        tableView.isHidden = true
        collectionView.isHidden = false
        
        categoryDatasourceDelegate.populate(category: selectedCategory)
    }
    
    func setSearchingState() {
        searchSelectorContainer.isHidden = false
        categoriesOuterContainer.isHidden = true
        filterButtonWidthConstraint.constant = 0
        cancelButton.isHidden = false
        isSearchState = true
        
        guard let term = searchField.text, term.count > 0 else {
            populateSearchWithNewestContent()
            return
        }
        
        populateSearchWith(term: term)
    }
    
    private func populateSearchWithNewestContent() {
        switch searchState {
        case .content:
            tableView.isHidden = true
            collectionView.isHidden = false
            searchVideosContentDatasourceDelegate.populate()
            searchVideosContentDatasourceDelegate.searchNewstVideos()
            
        case .people:
            tableView.isHidden = false
            collectionView.isHidden = true
            usersDatasourceDelegate.populate()
            usersDatasourceDelegate.searchNewstPeople()
            
        case .tags:
            tableView.isHidden = true
            collectionView.isHidden = false
            searchVideosTagsDatasourceDelegate.populate()
            searchVideosTagsDatasourceDelegate.searchNewstVideos()
        }
    }
    
    private func populateSearchWith(term: String) {
        switch searchState {
        case .content:
            tableView.isHidden = true
            collectionView.isHidden = false
            searchVideosContentDatasourceDelegate.populate()
            searchVideosContentDatasourceDelegate.search(term: term)
            
        case .people:
            tableView.isHidden = false
            collectionView.isHidden = true
            usersDatasourceDelegate.populate()
            usersDatasourceDelegate.search(term: term)
            
        case .tags:
            tableView.isHidden = true
            collectionView.isHidden = false
            searchVideosTagsDatasourceDelegate.populate()
            searchVideosTagsDatasourceDelegate.search(term: term)
        }
    }
    
    // MARK: Explore actions delegate
    
    func exploreActionGoToUser(user: User) {
        flowDelegate?.exploreGoToUser(vc: self, user: user)
    }
    
    func exploreActionFollowUser(user: User) {
        flowDelegate?.exploreHandleLoginAndDoAction(vc: self, completion: { wasPreviouslyAuthenticated in
            if wasPreviouslyAuthenticated {
                self.follow(user: user)
            } else {
                self.setCurrentState()
            }
        })
    }
    
    func exploreActionUnfollowUser(user: User) {
        flowDelegate?.exploreHandleLoginAndDoAction(vc: self, completion: { wasPreviouslyAuthenticated in
            if wasPreviouslyAuthenticated {
                self.unfollow(user: user)
            } else {
                self.setCurrentState()
            }
        })
    }
    
    func exploreActionGoToCategory(category: Category) {
        flowDelegate?.exploreGoToCategory(vc: self, category: category)
    }
    
    func exploreActionGoToVideoDetails(video: Video) {
        flowDelegate?.exploreGoToVideo(vc: self, video: video)
    }
    
    
    // MARK: Private methods
    
    private func unfollow(user: User) {
        loading = true
        userService.unfollowUser(user: user) { (result) in
            self.loading = false
            
            switch result {
            case .error:
                self.showGenericError()
                
            case .success:
                self.reloadCurrentUser()
            }
        }
    }
    
    private func follow(user: User) {
        loading = true
        userService.followUser(user: user) { (result) in
            self.loading = false
            
            switch result {
            case .error:
                self.showGenericError()
                
            case .success:
                self.reloadCurrentUser()
            }
        }
    }
    
    private func reloadCurrentUser() {
        loading = true
        userService.getCurrentUser { (result) in
            self.loading = false
            switch result {
            case .error:
                self.showGenericError()
                
            case .success(let user):
                Context.current.user = user
                
                self.reloadDataSources()
            }
        }
    }
    
    private func reloadDataSources() {
        forYouDatasourceDelegate.reloadDataWithoutLoad()
        categoryDatasourceDelegate.reloadDataWithoutLoad()
        usersDatasourceDelegate.reloadDataWithoutLoad()
        searchVideosContentDatasourceDelegate.reloadDataWithoutLoad()
        searchVideosTagsDatasourceDelegate.reloadDataWithoutLoad()
    }
    
    private func clearSearch() {
        usersDatasourceDelegate.clearItems()
        searchVideosTagsDatasourceDelegate.clearItems()
        searchVideosContentDatasourceDelegate.clearItems()
    }
}
