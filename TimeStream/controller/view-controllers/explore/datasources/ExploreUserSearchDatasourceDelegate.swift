//
//  ExploreUserSearchDatasourceDelegate.swift
//  TimeStream
//
//  
//

import UIKit
import SwiftUI

class ExploreUserSearchDatasourceDelegate: NSObject, UITableViewDelegate, UITableViewDataSource, UserTableViewCellDelegate {
    
    weak var actionsDelegate: ExploreActionsDelegate?
    
    private struct Constants {
        static let cellIdentifier = "UserTableViewCell"
    }
    
    private let tableView: UITableView
    private var users = [User]()
    private var currentPage = 1
    private var term: String?
    private var newContent = false
    
    private let service = ExploreService()
    
    // MARK: Lifecycle
    
    init(tableView: UITableView) {
        self.tableView = tableView
        
        super.init()
        
        tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
    }
    
    // MARK: Public
    
    func populate() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
        tableView.reloadData()
        
        tableView.startAutoRefresh {
            if self.newContent {
                self.loadNewestItems()
                
                return
            }
            
            guard let term = self.term else {
                self.tableView.endCurrentRefresh()
                return
            }
            
            self.loadItems(term: term)
        }
    }
    
    func search(term: String) {
        newContent = false
        guard term != self.term else {
            return
        }
        
        currentPage = 1
        users.removeAll()
        tableView.reloadData()
        self.term = term
        
        loadItems(term: term)
    }
    
    func searchNewstPeople() {
        newContent = true
        currentPage = 1
        users.removeAll()
        tableView.reloadData()
        
        loadNewestItems()
    }
    
    func clearItems() {
        users.removeAll()
        tableView.reloadData()
        
        term = nil
    }
    
    func reloadDataWithoutLoad() {
        tableView.reloadData()
    }
    
    // MARK: Scroll view delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (tableView.numberOfSections > 0) && (tableView.numberOfRows(inSection: 0) > 0) {
            tableView.superview?.endEditing(true)
        }
    }
    
    // MARK: Private methods
    
    private func loadItems(term: String) {
        guard term.count > 0 else {
            tableView.endCurrentRefresh()
            return
        }
        
        tableView.beginRefresh()
        service.searchPeople(term: term, page: currentPage) { result in
            self.tableView.endCurrentRefresh()

            switch result {
            case .error:
                break

            case .success(let users):
                self.users.removeExtraItems(pageSize: AppConstants.numberOfItemsPerPage)
                self.users += users

                if users.count == AppConstants.numberOfItemsPerPage {
                    // Increase the page number
                    self.currentPage += 1
                }

                self.tableView.reloadData()
            }
        }
    }
    
    private func loadNewestItems() {
        tableView.beginRefresh()
        service.newestPeople(page: currentPage) { result in
            self.tableView.endCurrentRefresh()

            switch result {
            case .error:
                break

            case .success(let users):
                self.users.removeExtraItems(pageSize: AppConstants.numberOfItemsPerPage)
                self.users += users

                if users.count == AppConstants.numberOfItemsPerPage {
                    // Increase the page number
                    self.currentPage += 1
                }

                self.tableView.reloadData()
            }
        }
    }

    // MARK: Data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let items = users.count
        
        if items == 0 {
            tableView.setMessageExplore("no.items.for.your.search.criteria".localized)
        } else {
            tableView.clearBackground()
        }
        
       return items
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! UserTableViewCell
        cell.delegate = self

        let user = users[indexPath.row]

        cell.populate(user: user, currentUser: Context.current.user)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    // MARK: Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        actionsDelegate?.exploreActionGoToUser(user: user)
    }
    
    // MARK: User cell delegate
    
    func didTapFollow(cell: UserTableViewCell, user: User) {
        actionsDelegate?.exploreActionFollowUser(user: user)
    }
    
    func didTapUnfollow(cell: UserTableViewCell, user: User) {
        actionsDelegate?.exploreActionUnfollowUser(user: user)
    }
    
}
