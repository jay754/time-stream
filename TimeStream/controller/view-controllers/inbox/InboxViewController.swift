//
//  InboxViewController.swift
//  TimeStream
//
//  Created by appssemble on 03.07.2021.
//

import UIKit

protocol InboxFlowDelegate: BaseViewControllerFlowDelegate {
    func inboxGoToUser(vc: InboxViewController, user: User)
    func inboxGoToRequest(vc: InboxViewController)
    func inboxGoToEarnings(vc: InboxViewController)
    func inboxGoToConversation(vc: InboxViewController, conversation: Conversation)
}

class InboxViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var flowDelegate: InboxFlowDelegate?
    
    private struct Constants {
        static let cellIdentifier = "InboxTableViewCell"
    }
    
    @IBOutlet weak var statsContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    private let userService = UserService()
    private let conversationService = ConversationService()
    private let paymentsService = BackendPaymentService()
    private var conversations = [Conversation]() {
        didSet {
            shownConversations = conversations
        }
    }
    
    @IBOutlet weak var totalEarnedLabel: UILabel!
    private var shownConversations = [Conversation]()
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        statsContainer.addOutterShadowBottomLarge()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "InboxTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        
        searchTextField.addTarget(self, action: #selector(searchHasChangedKeyword), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
        
        loadConversations()
    }

    // MARK: Table view datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shownConversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! InboxTableViewCell
        cell.populate(conversation: shownConversations[indexPath.row])
        
        return cell
    }
    
    // MARK: Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = shownConversations[indexPath.row]
        
        flowDelegate?.inboxGoToConversation(vc: self, conversation: conversation)
    }
    
    // MARK: Search delegate
    
    @objc
    func searchHasChangedKeyword() {
        let text = searchTextField.text ?? ""
        
        if text.count == 0 {
            shownConversations = conversations
            tableView.reloadData()
            
            return
        }
        
        shownConversations = conversations.filter({$0.otherUser.name.contains(text)})
        tableView.reloadData()
    }
    
    
    // MARK: Actions
    
    @IBAction func goToEarnings(_ sender: Any) {
        flowDelegate?.inboxGoToEarnings(vc: self)
    }
    
    // MARK: Private
    
    func loadConversations() {
        loading = true
        conversationService.getConversations(currencyCode: Currency.current().rawValue) { result in
            self.loading = false
            
            switch result {
            case.error:
                self.showGenericError()
                
            case .success(let conversations):
                self.conversations = conversations.sorted(by: {$0.lastVideo.createdAt > $1.lastVideo.createdAt})
                self.tableView.reloadData()
                
                self.loadEarnedAmount()
            }
        }
    }
    
    func loadEarnedAmount() {
        loading = true
        paymentsService.getTotalEarned { result in
            self.loading = false
            
            switch result {
            case .error:
                self.showGenericError()
                
            case .success(let earnedAmount):
                self.totalEarnedLabel.text = earnedAmount.amountCents.formattedPriceDecimals(currency: earnedAmount.currency)
            }
        }
    }
}
