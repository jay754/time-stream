//
//  RequestViewController.swift
//  TimeStream
//
//  Created by appssemble on 28.10.2021.
//

import UIKit

protocol RequestViewControllerFlowDelegate: BaseViewControllerFlowDelegate {
    func requestGoToResponse(vc: RequestViewController, message: VideoMessage, conversation: Conversation)
}

class RequestViewController: BaseViewController {
    
    weak var flowDelegate: RequestViewControllerFlowDelegate?
    var message: VideoMessage!
    var conversation: Conversation!

    @IBOutlet weak var videoViewContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionsContainerView: UIView!
    
    private let videoView = VideoView.loadFromNib()
    private let conversationService = ConversationService()
    private let paymentService = BackendPaymentService()
    private var adyenPaymentHelper: AdyenPaymentHelper!
    private let reportHelper = ReportHelper()
    private let userService = UserService()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        adyenPaymentHelper = AdyenPaymentHelper(vc: self)
        
        videoViewContainer.addSubview(videoView)
        videoView.setMedia(url: message.videoPath)
        
        titleLabel.text = "request.from".localized + " " + conversation.otherUser.name
        
        actionsContainerView.isHidden = message.responseVideoMessageID != nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        videoView.isPlaying = true
        markVideoAsSeen()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        videoView.isPlaying = false
    }
    
    // MARK: Actions
    
    @IBAction func moreTapped(_ sender: Any) {
        reportHelper.reportConversationVideo(videoMessageID: message.id, from: self)
    }
    
    @IBAction func videoTap(_ sender: Any) {
        videoView.isPlaying = !videoView.isPlaying
    }
    
    @IBAction func accept(_ sender: Any) {
        fetchCurrentUser {
            self.loading = true
            self.adyenPaymentHelper.hasBankAccountAdded { (result) in
                self.loading = false
                
                switch result {
                case .error:
                    self.showAlert(message: "set.bank.message".localized)
                    
                case .success(let account):
                    if !account.accountValid || account.pendingAuthorization {
                        // If the account is not yet authorized or there are pending authorizations, redirect to Stripe account setup
                        self.showAlert(message: "set.bank.message".localized) {
                            self.openBankAccount()
                        }
                        
                    } else {
                        self.flowDelegate?.requestGoToResponse(vc: self, message: self.message, conversation: self.conversation)
                    }
                }
            }
        }
    }
    
    @IBAction func decline(_ sender: Any) {
        loading = true
        conversationService.declineVideoMessage(message: message) { result in
            self.loading = false
            
            switch result {
            case .success:
                self.flowDelegate?.backButtonPressed(from: self)
                
            case .error:
                self.showGenericError()
            }
        }
    }
    
    @IBAction func backPressed(_ sender: Any) {
        flowDelegate?.backButtonPressed(from: self)
    }
    
    // MARK: Private methods
    
    private func openBankAccount() {
        videoView.isPlaying = false
        adyenPaymentHelper.openOnboardingScreen { [weak self] in
            // Do nothing
            self?.videoView.isPlaying = true
        }
    }
    
    private func markVideoAsSeen() {
        conversationService.markVideoMessageAsSeen(message: message) { result in
            // Do nothing
        }
    }
    
    private func fetchCurrentUser(completion: EmptyClosure?) {
        loading = true
        userService.getCurrentUser { result in
            self.loading = false
            
            switch result {
            case.error:
                completion?()
                
            case .success(let user):
                Context.current.user = user
                completion?()
            }
        }
    }
    
}
