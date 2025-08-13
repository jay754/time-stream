//
//  ExploreForYourDatasourceDelegate.swift
//  TimeStream
//
//  Created on 08.12.2021.
//

import Foundation
import UIKit



class ExploreForYouDatasourceDelegate: NSObject, UITableViewDataSource, UITableViewDelegate, ExplorePageHeaderViewDelegate, ContentCreatorsTableViewCellDelegate, ExploreVideosTableViewCellDelegate {
    
    weak var actionsDelegate: ExploreActionsDelegate?
    
    private struct Constants {
        static let creatorsCell = "ContentCreatorsTableViewCell_exploreForYou"
        static let videosCell = "ExploreVideosTableViewCell_exploreForYou"
    }
    
    private let tableView: UITableView
    private var hasCreators: Bool {
        get {
            return creators.count != 0
        }
    }
    
    private var videos = [Category: [Video]]() {
        didSet {
            keys = Array(videos.keys.sorted(by: {$0.name < $1.name}))
        }
    }
    
    private var keys = [Category]()
    private var creators = [User]()
    private var categories = [Category]()
    private let exploreService = ExploreService()
    
    
    // MARK: Lifecycle
    
    init(tableView: UITableView) {
        self.tableView = tableView
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: .leastNonzeroMagnitude))
        
        super.init()
        
        tableView.register(UINib(nibName: "ContentCreatorsTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.creatorsCell)
        tableView.register(UINib(nibName: "ExploreVideosTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.videosCell)
    }
    
    // MARK: Public
    
    func populate(categories: [Category]) {
        self.categories = categories
        self.videos.removeAll()
        self.creators.removeAll()

        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        tableView.startAutoRefresh {
            self.tableView.endCurrentRefresh()
        }
    }
    
    func loadData() {
        loadCreators()
        loadVideos()
    }
    
    func reloadDataWithoutLoad() {
        tableView.reloadData()
    }
    
    // MARK: Private methids
    
    private func loadCreators() {
        tableView.beginRefresh()
        exploreService.popularCreators(categories: categories) { result in
            self.tableView.endCurrentRefresh()

            switch result {
            case .error:
                // Do nothing
                break

            case .success(let users):
                self.creators = users
                self.tableView.reloadData()
            }
        }
    }
    
    private func loadVideos() {
        tableView.beginRefresh()
        exploreService.popularVideos(categories: categories) { result in
            self.tableView.endCurrentRefresh()

            switch result {
            case .error:
                // Do nothing
                break

            case .success(let videos):
                self.videos = videos
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: Datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let keys = keys.count
        
        if hasCreators {
            return keys + 1
        }
        
        return keys
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.clearBackground()
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && hasCreators {
            // Creator
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.creatorsCell, for: indexPath) as! ContentCreatorsTableViewCell
            cell.populate(users: creators)
            cell.delegate = self
            
            return cell
        }
        
        // Videos
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.videosCell, for: indexPath) as! ExploreVideosTableViewCell
        cell.delegate = self
        var index = indexPath.section
        if hasCreators {
            index -= 1
        }
        
        if let videos = videos[keys[index]] {
            cell.populate(videos: videos)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title = "popular.creators".localized
        var category: Category?
        
        if section > 0 && hasCreators {
            // has creators and another section
            title = keys[section - 1].name
            category = keys[section - 1]
        }
        
        if !hasCreators {
            title = keys[section].name
            category = keys[section]
        }
        
        let view = ExplorePageHeaderView.loadFromNib()
        let seeAll = !(hasCreators && section == 0)
        view.setTitle(title: title, seeAll: seeAll, category: category)
        view.delegate = self
        
        return view
    }
    
    // MARK: Scroll view delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (tableView.numberOfSections > 0) && (tableView.numberOfRows(inSection: 0) > 0) {
            tableView.superview?.endEditing(true)
        }
    }
    
    // MARK: Table view delegate
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    // MARK: Explore page delegate
    
    func exploreHeaderViewAll(view: ExplorePageHeaderView, category: Category) {
        actionsDelegate?.exploreActionGoToCategory(category: category)
    }
    
    // MARK: Content creator cell delegate
    
    func contentCreatorCellFollow(cell: ContentCreatorsTableViewCell, user: User) {
        actionsDelegate?.exploreActionFollowUser(user: user)
    }
    
    func contentCreatorCellGoTo(cell: ContentCreatorsTableViewCell, user: User) {
        actionsDelegate?.exploreActionGoToUser(user: user)
    }
    
    // MARK: Explore video cell delegate
    
    func exploreVideosCellGoToVideo(cell: ExploreVideosTableViewCell, video: Video) {
        actionsDelegate?.exploreActionGoToVideoDetails(video: video)
    }
}
