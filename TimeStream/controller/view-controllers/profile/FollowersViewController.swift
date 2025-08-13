//
//  FollowersViewController.swift
//  TimeStream
//
//  Created by appssemble on 17.08.2021.
//

import UIKit

protocol FollowersViewControllerFlowDelegate: BaseViewControllerFlowDelegate {
    func followersGoToUser(vc: FollowersViewController, user: User)
}

class FollowersViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UserTableViewCellDelegate {
    
    weak var flowDelegate: FollowersViewControllerFlowDelegate?
    
    var forUser: User!
    var currentUser: User!
    
    struct Constants {
        static let cellIdentifier = "UserTableViewCell"
    }
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    private var users = [User]()
    private var filter = [User]()
    
    private var data = [User]()
    private var userService = UserService()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addBackButton(delegate: flowDelegate)
        
        tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        searchTextField.addTextChangeObserver(item: self, selector: #selector(searchFieldTextChanged))
        
        guard let user = Context.current.user else {
            flowDelegate?.backButtonPressed(from: self)
            return
        }
        
        currentUser = user
        loadFollowers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: Data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! UserTableViewCell
        cell.delegate = self
        
        let user = data[indexPath.row]
        cell.populate(user: user, currentUser: currentUser)
        
        return cell
    }
    
    // MARK: Text changed
    
    @objc
    private func searchFieldTextChanged() {
        guard let searchText = searchTextField.text,
              searchText.count > 0 else {
            data = users
            tableView.reloadData()
            return
        }
        
        filter = users.filter({$0.name.lowercased().contains(searchText.lowercased())})
        data = filter
        tableView.reloadData()
    }
    
    // MARK: Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = data[indexPath.row]
        flowDelegate?.followersGoToUser(vc: self, user: user)
    }
    
    // MARK: User cell delegate
    
    func didTapFollow(cell: UserTableViewCell, user: User) {
        loading = true
        userService.followUser(user: user) { (result) in
            self.loading = false
            
            switch result {
            case .error:
                self.showGenericError()
            case .success:
                self.loadCurrentUser {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func didTapUnfollow(cell: UserTableViewCell, user: User) {
        loading = true
        userService.unfollowUser(user: user) { (result) in
            self.loading = false
            
            switch result {
            case .error:
                self.showGenericError()
            case .success:
                self.loadCurrentUser {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: Private methods
    
    private func loadFollowers() {
        loading = true
        userService.getFollowing(user: forUser) { (result) in
            self.loading = false
            
            switch result {
            case .error:
                self.showGenericError()
                
            case .success(let users):
                self.users = users
                self.data = users
                self.tableView.reloadData()
            }
        }
    }
    
    private func loadCurrentUser(completion: EmptyClosure?) {
        loading = true
        userService.getCurrentUser { (result) in
            self.loading = false
            switch result {
            case .error:
                self.showGenericError()
                
            case .success(let user):
                Context.current.user = user
                self.currentUser = user
                completion?()
            }
        }
    }
}
