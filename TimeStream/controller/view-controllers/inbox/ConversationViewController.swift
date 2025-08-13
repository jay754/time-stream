//
//  ConversationViewController.swift
//  TimeStream
//
//  Created by appssemble on 01.11.2021.
//

import UIKit

protocol ConversationViewControllerFlowDelegate: BaseViewControllerFlowDelegate {
    func conversationGoToReply(vc: ConversationViewController, videoMessage: VideoMessage, conversation: Conversation)
    func conversationGoToRequest(vc: ConversationViewController, videoMessage: VideoMessage, conversation: Conversation)
    func conversationGoToNoAction(vc: ConversationViewController, videoMessage: VideoMessage, conversation: Conversation)
    
    func conversationGoToNewInteraction(vc: ConversationViewController, otherUser: User)
    func conversationGoToUser(vc: ConversationViewController, user: User)
}

class ConversationViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var flowDelegate: ConversationViewControllerFlowDelegate?
    var conversation: Conversation!
    
    private struct Constants {
        static let currentUserCell = "CurrentUserConversationTableViewCell"
        static let otherUserCell = "OtherUserConversationTableViewCell"
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private let service = ConversationService()
    private var messages = [VideoMessage]()
    
    @IBOutlet weak var interactButtonContainer: UIView!
    @IBOutlet weak var interactButtonImageView: UIImageView!
    @IBOutlet weak var interactButton: UIButton!
    
    private let userService = UserService()
    
    private var currentUser: User!
    var scrollToBottomOnLoad = true
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        interactButtonContainer.addOutterShadow()

        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
        tableView.register(UINib(nibName: "CurrentUserConversationTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.currentUserCell)
        tableView.register(UINib(nibName: "OtherUserConversationTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.otherUserCell)
        
        reloadCurrentUser()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        setConversationDetails()
        setInteractionButtonState(user: conversation.otherUser)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        
        reloadData(scrollToBottom: scrollToBottomOnLoad)
        scrollToBottomOnLoad = false
        loadOtherUser()
    }
    
    // MARK: Actions
    
    @IBAction func addInteraction(_ sender: Any) {
        flowDelegate?.conversationGoToNewInteraction(vc: self, otherUser: conversation.otherUser)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        flowDelegate?.backButtonPressed(from: self)
    }
    
    @IBAction func goToUser(_ sender: Any) {
        flowDelegate?.conversationGoToUser(vc: self, user: conversation.otherUser)
    }
    
    // MARK: Table view datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        if message.userID == currentUser.id {
            // Current user cell
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.currentUserCell, for: indexPath) as! CurrentUserConversationTableViewCell
            cell.populate(message: message)
            
            return cell
        }
        
        // Other user cell
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.otherUserCell, for: indexPath) as! OtherUserConversationTableViewCell
        cell.populate(message: message)
        
        return cell
    }
    
    // MARK: Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let currentUser = Context.current.user else {
            return
        }
        
        if message.type == .interact && message.userID != currentUser.id  {
            // Request
            flowDelegate?.conversationGoToRequest(vc: self, videoMessage: message, conversation: conversation)
            return
        }
        
        if message.type == .response && message.userID != currentUser.id  {
            // Reply
            flowDelegate?.conversationGoToReply(vc: self, videoMessage: message, conversation: conversation)
            return
        }
        
        // No action Message
        flowDelegate?.conversationGoToNoAction(vc: self, videoMessage: message, conversation: conversation)
    }
    
    // MARK: Private methods
    
    private func reloadData(scrollToBottom: Bool = false) {
        loading = true
        service.getMessages(conversationID: conversation.id) { result in
            self.loading = false
            
            switch result {
            case .error:
                self.showGenericError()
                
            case .success(let messages):
                self.messages = messages.sorted(by: {$0.createdAt < $1.createdAt})
                
                self.tableView.reloadData()
                if scrollToBottom {
                    self.tableView.scrollToBottom()
                }
            }
        }
    }
    
    private func reloadCurrentUser() {
        guard let user = Context.current.user else {
            flowDelegate?.backButtonPressed(from: self)
            showGenericError()
            return
        }
        
        currentUser = user
    }
    
    private func loadOtherUser() {
        userService.getUser(id: conversation.otherUser.id, currencyCode: Currency.current().rawValue) { result in
            switch result {
            case .error:
                break
                
            case .success(let otherUser):
                self.setInteractionButtonState(user: otherUser)
            }
        }
    }
    
    private func setConversationDetails() {
        nameLabel.text = conversation.otherUser.name
        userImageView.setUserImage(url: conversation.otherUser.photoURL)
    }
    
    private func setInteractionButtonState(user: User) {
        if user.availableInteractions > 0 {
            // Button is enabled
            interactButton.isUserInteractionEnabled = true
            interactButtonImageView.image = UIImage(named: "interact-button")
        } else {
            interactButton.isUserInteractionEnabled = false
            interactButtonImageView.image = UIImage(named: "interact-button-disabled")
        }
    }
}
