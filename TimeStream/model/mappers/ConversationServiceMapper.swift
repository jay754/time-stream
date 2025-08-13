//
//  ConversationServiceMapper.swift
//  TimeStream
//
//  Created by appssemble on 04.11.2021.
//

import Foundation

class ConversationServiceMapper {
    
    private struct Constants {
        static let videoPath = "video_path"
        static let toUserID = "to_user_id"
        static let localIntentID = "local_intent_id"
        static let thumbnailPath = "thumbnail_path"
        
        static let id = "id"
        static let userID = "user_id"
        static let messageType = "message_type"
        static let conversationID = "conversation_id"
        static let createdAt = "created_at"
        static let active = "active"
        static let seen = "seen"
        static let responseVideoMessageID = "response_video_message_id"
        
        static let otherUser = "other_user"
        static let latestMessage = "latest_message"
        static let conversations = "conversations"
        
        static let thumbnailURL = "thumbnail_url"
        static let videoURL = "video_url"
        
        static let messages = "messages"
        static let postedVideoID = "posted_video_id"
        
        static let description = "description"
        static let tags = "tags"
        
        static let privateVideo = "private"
        static let category = "category"
    }
    
    private let userMapper = UserMapper()
    
    // MARK: Methods
    
    func addVideoRequestParams(user: User, paymentIntent: PaymentIntent) -> [String: Any] {
        return [Constants.toUserID: user.id,
                Constants.localIntentID: paymentIntent.id]
    }
    
    func addVideoResponseParams(video: PresignedUpload, thumbnail: PresignedUpload) -> [String: Any] {
        return [Constants.videoPath: video.path,
                Constants.thumbnailPath: thumbnail.path]
    }
    
    func addVideoToProfileParams(privateVideo: Bool, description: String, tags: [String], category: Category) -> [String: Any] {
        var dict = [Constants.description: description,
                    Constants.tags: tags,
                    Constants.category: category.rawValue,
                    Constants.privateVideo: privateVideo] as [String: Any]
        return dict
    }
    
    func mapConversations(dict: [String: Any]) -> [Conversation]? {
        var conversations = [Conversation]()
        
        guard let convs = dict[Constants.conversations] as? [[String: Any]] else {
            return nil
        }
        
        for dict in convs {
            if let conv = mapConversation(dict: dict) {
                conversations.append(conv)
            }
        }
        
        return conversations
    }
    
    func mapVideoMessages(dict: [String: Any]) -> [VideoMessage]? {
        var messages = [VideoMessage]()
        
        guard let msgs = dict[Constants.messages] as? [[String: Any]] else {
            return nil
        }
        
        for dict in msgs {
            if let msg = mapVideoMessage(dict: dict) {
                messages.append(msg)
            }
        }
        
        return messages
    }
    
    // MARK: Private methods
    
    private func mapConversation(dict: [String: Any]) -> Conversation? {
        guard let id = dict[Constants.id] as? Int,
              let otherUserDict = dict[Constants.otherUser] as? [String: Any],
                let otherUser = userMapper.mapUser(dict: otherUserDict),
              let latestMessageDict = dict[Constants.latestMessage] as? [String: Any],
              let latestMessage = mapVideoMessage(dict: latestMessageDict) else {
                  
                  return nil
              }
        
        return Conversation(id: id, otherUser: otherUser, lastVideo: latestMessage)
    }
    
    private func mapVideoMessage(dict: [String: Any]) -> VideoMessage? {
        guard let id = dict[Constants.id] as? Int,
              let userID = dict[Constants.userID] as? Int,
              let videoPathStr = dict[Constants.videoURL] as? String,
              let videoPath = URL(string: videoPathStr),
              let messageTypeStr = dict[Constants.messageType] as? String,
              let messageType = VideoMessageType(rawValue: messageTypeStr),
              let conversationID = dict[Constants.conversationID] as? Int,
              let createdAtStr = dict[Constants.createdAt] as? String,
              let createdAt = Date.dateFromBackend(string: createdAtStr),
              let thumbnailStr = dict[Constants.thumbnailURL] as? String,
              let thumbnail = URL(string: thumbnailStr),
              let seen = dict[Constants.seen] as? Bool else {
                  
                  return nil
              }
        
        let videoID = dict[Constants.postedVideoID] as? Int
        let responseVideoMessageID = dict[Constants.responseVideoMessageID] as? Int
              
        return VideoMessage(id: id, userID: userID, videoPath: videoPath, thumbnailPath: thumbnail, conversationID: conversationID, createdAt: createdAt, type: messageType, seen: seen, postedVideoID: videoID, responseVideoMessageID: responseVideoMessageID)
    }
}
