//
//  ConversationService.swift
//  TimeStream
//
//  Created by appssemble on 04.11.2021.
//

import UIKit

typealias ConversationsClosure = (_ result: Result<[Conversation]>) -> Void
typealias VideoMessageClosure = (_ result: Result<[VideoMessage]>) -> Void

class ConversationService {
    
    private struct Constants {
        static let conversations = "conversations/"
        
        static let presignedVideoURL = conversations + "presigned_conversation_video_url"
        static let presignedThumbnailURL = conversations + "presigned_conversation_thumbnail_url"
        
        static let addRequest = conversations + "add_request"
        static let currentUserConversations = conversations + "current_user_conversations"
        
        static let messages = "/messages"
        
        static let conversationMessages = conversations + "messages"
        static let markAsSeen = "mark_as_seen"
        static let decline = "decline_video_message"
        static let addResponse = "add_response"
        static let addVideoToProfile = "add_video_to_profile"
    }
    
    private let service = ServiceHelper()
    private let userMapper = UserMapper()
    private let videoMapper = VideoMapper()
    private let conversationMapper = ConversationServiceMapper()
    
    // MARK: Methods
    
    
    func addVideoRequest(video: URL, thumbnail: UIImage, paymentIntent: PaymentIntent, forUser: User, progress: ProgressClosure?, completion: @escaping VoidClosure) {
        let params = conversationMapper.addVideoRequestParams(user: forUser, paymentIntent: paymentIntent)
        
        service.multipartFormUpload(path: Constants.addRequest, video: video, thumbnail: thumbnail, params: params, progress: progress) { response in
            
            switch response {
            case .success:
                completion(.success(()))
                
            case .error(let error):
                completion(.error(error))
            }
        }
    }
    
    func addVideoResponse(message: VideoMessage, video: URL, thumbnail: UIImage, progressClosure: ProgressClosure?, completion: @escaping VoidClosure) {
        let path = Constants.conversationMessages + "/\(message.id)/" + Constants.addResponse
        
        service.multipartFormUpload(path: path, video: video, thumbnail: thumbnail, params: [:], progress: progressClosure) { response in
            switch response {
            case .success:
                completion(.success(()))
                
            case .error(let error):
                completion(.error(error))
            }
        }
    }
    
    func addVideoToProfile(message: VideoMessage, thumbnail: UIImage?, privateVideo: Bool, description: String, tags: [String], category: Category, progress: ProgressClosure?, completion: @escaping VoidClosure) {
        
        let params = conversationMapper.addVideoToProfileParams(privateVideo: privateVideo,
                                                                description: description,
                                                                tags: tags,
                                                                category: category)
        
        let path = Constants.conversationMessages + "/\(message.id)/" + Constants.addVideoToProfile
        service.multipartFormUpload(path: path, video: nil, thumbnail: thumbnail, params: params, progress: progress) { response in
            switch response {
            case .success:
                completion(.success(()))
                
            case .error(let error):
                completion(.error(error))
            }
        }
    }
    
    func markVideoMessageAsSeen(message: VideoMessage, completion: @escaping VoidClosure) {
        let path = Constants.conversationMessages + "/\(message.id)/" + Constants.markAsSeen

        service.POST(path: path, data: nil) { response in
            switch response {
            case .success:
                completion(.success(()))
                
            case .error(let error):
                completion(.error(error))
            }
        }
    }
    
    func declineVideoMessage(message: VideoMessage, completion: @escaping VoidClosure) {
        let path = Constants.conversationMessages + "/\(message.id)/" + Constants.decline

        service.POST(path: path, data: nil) { response in
            switch response {
            case .success:
                completion(.success(()))
                
            case .error(let error):
                completion(.error(error))
            }
        }
    }
    
    func getConversations(currencyCode: String, completion: @escaping ConversationsClosure) {
        service.GET(path: Constants.currentUserConversations, data: userMapper.currencyCodeParams(code: currencyCode)) { (result) in
            switch result {
            case .success(let dict):
                if let convs = self.conversationMapper.mapConversations(dict: dict) {
                    completion(.success(convs))
                    return
                }
                
                completion(.error(nil))
                
            case .error(let error):
                completion(.error(error))
            }
        }
    }
    
    func getMessages(conversationID: Int, completion: @escaping VideoMessageClosure) {
        let path = Constants.conversations + "\(conversationID)" + Constants.messages
        
        service.GET(path: path, data: nil) { (result) in
            switch result {
            case .success(let dict):
                if let convs = self.conversationMapper.mapVideoMessages(dict: dict) {
                    completion(.success(convs))
                    return
                }
                
                completion(.error(nil))
                
            case .error(let error):
                completion(.error(error))
            }
        }
    }
}
