//
//  DeepLinkingManager.swift
//  TimeStream
//
//  Created by appssemble on 25.10.2021.
//

import Foundation
import FirebaseDynamicLinks


protocol DeepLinkingManagerDelegate: AnyObject {
    func deepLinkingGoToVideo(manager: DeepLinkingManager, video: Video)
    func deepLinkingGoToUser(manager: DeepLinkingManager, user: User)
}

class DeepLinkingManager {
    
    weak var delegate: DeepLinkingManagerDelegate?
    
    private let dynamicLinkHelper = DynamicLinkHelper()
    private let videoService = VideoService()
    private let userService = UserService()
    
    // MARK: Methods
    
    func handleLink(link: URL) {
        if((link.host?.contains("profile")) != nil){
            if(link.path.contains("/u/")){
                self.loadUserWithByUsername(username: link.lastPathComponent)
                return
            }else if(link.path.contains("user")){
                self.loadUserWith(id: Int(link.lastPathComponent)!)
                return
            }else{
                self.loadUserWithByUsername(username: link.lastPathComponent)
                return
            }
        }
        DynamicLinks.dynamicLinks().handleUniversalLink(link) { dynamiclink, error in
            guard let dynamicLink = dynamiclink,
            let url = dynamicLink.url else {
                return
            }
            
            let action = self.dynamicLinkHelper.getActionForLink(link: url)
            self.handleAction(action: action)
        }
    }
    
    // MARK: Private
    
    private func handleAction(action: DynamicLinksActions) {
        switch action {
        case .video(let id):
            self.loadVideoWith(id: id)
            
        case .user(let id):
            self.loadUserWith(id: id)
            
        case .noAction:
            break
        }
    }
    
    private func loadVideoWith(id: Int) {
        videoService.getVideo(videoID: id) { result in
            switch result {
            case .success(let video):
                self.delegate?.deepLinkingGoToVideo(manager: self, video: video)
                
            case .error:
                break
            }
        }
    }
    
    private func loadUserWith(id: Int) {
        userService.getUser(id: id, currencyCode: Currency.current().rawValue) { (result) in
            switch result {
            case .error:
                break
                
            case .success(let user):
                self.delegate?.deepLinkingGoToUser(manager: self, user: user)
            }
        }
    }
    
    private func loadUserWithByUsername(username: String) {
        userService.getUserByUsername(username: username, currencyCode: Currency.current().rawValue) { (result) in
            switch result {
            case .error:
                break
                
            case .success(let user):
                self.delegate?.deepLinkingGoToUser(manager: self, user: user)
            }
        }
    }
    
}
