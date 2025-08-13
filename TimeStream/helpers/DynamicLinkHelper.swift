//
//  DynamicLinkHelper.swift
//  TimeStream
//
//  Created by appssemble on 11.08.2021.
//

import UIKit
import FirebaseDynamicLinks


enum DynamicLinksActions {
    case noAction
    case video(id: Int)
    case user(id: Int)
}

class DynamicLinkHelper {
    
    private struct Constants {
        static let defaultLink = "https://timestream.page.link"
        
        static let bundle = "com.appssemble.time-stream"
        static let android = "com.appssemble.time_android"
        static let iosAppstoreId = "1607803576"
        
        static let generalLink = "/general-link"
        static let video = "/video/"
        static let user = "/user/"
        static let basePublicUrl = "https://time.stream"
        static let profilePublicUrl = "https://profile.time.stream"
    }
    
    func showShareAppSheet(from: BaseViewController) {
        from.loading = true
        getLink(path: Constants.generalLink, title: "TIME", description: "Your questions answered", imageURL: nil) { (url) in
            from.loading = false
            
            guard let url = url else {
                return
            }
            
            let activityViewController = UIActivityViewController(activityItems: [url, "Ask the experts, your video questions answered"], applicationActivities: nil)
            from.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func showShareVideoSheet(from: BaseViewController, video: Video) {
        from.loading = true
        let path = Constants.video + "\(video.id)"
        
        getLink(path: path, title: "TIME", description: "Check out this video", imageURL: nil) { (url) in
            from.loading = false
            
            guard let url = url else {
                return
            }
            
            let activityViewController = UIActivityViewController(activityItems: [url, "Ask the experts, your video questions answered\n\n"+video.description.limit(length: 50)+" on TIME"], applicationActivities: nil)
            from.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func showShareUserSheet(from: BaseViewController, user: User) {
        /*from.loading = true
        let path = Constants.user + "\(user.id)"
        
        getLink(path: path, title: "TIME", description: "Check out this profile", imageURL: nil) { (url) in
            from.loading = false
            
            guard let url = url else {
                return
            }
            
            let activityViewController = UIActivityViewController(activityItems: [url, "Ask the experts, your video questions answered\n\n"+user.name+" on TIME"], applicationActivities: nil)
            from.present(activityViewController, animated: true, completion: nil)
        }*/
        
        //let url = Constants.profilePublicUrl + "/" + user.username + (user.id == Context.current.user?.id ? "/my" : "")
        let url = Constants.profilePublicUrl + "/u/" + user.username
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        from.present(activityViewController, animated: true, completion: nil)
        
    }
    	
    func getActionForLink(link: URL) -> DynamicLinksActions {
        let str = link.absoluteString
        if !str.hasPrefix(Constants.defaultLink) {
            return .noAction
        }
        
        let path = str.replacingOccurrences(of: Constants.defaultLink, with: "")
        if path.hasPrefix(Constants.video) {
            let id = path.replacingOccurrences(of: Constants.video, with: "")
            if let number = Int(id) {
                return .video(id: number)
            }
        }
        
        if path.hasPrefix(Constants.user) {
            let id = path.replacingOccurrences(of: Constants.user, with: "")
            if let number = Int(id) {
                return .user(id: number)
            }
        }
        
        return .noAction
    }
    
    // MARK: Private methods
    
    private func getLink(path: String, title: String, description: String, imageURL: String?, completion: @escaping ShareURL) {
        guard let link = URL(string: Constants.defaultLink + path) else {
            completion(nil)

            return
        }

        let dynamicLinksDomainURIPrefix = Constants.defaultLink
        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix)

        let iOSParams = DynamicLinkIOSParameters(bundleID: Constants.bundle)
        iOSParams.appStoreID = Constants.iosAppstoreId
        linkBuilder?.iOSParameters = iOSParams


        let androidParams = DynamicLinkAndroidParameters(packageName: Constants.android)
        linkBuilder?.androidParameters = androidParams

        let otherPlatform = DynamicLinkOtherPlatformParameters()
        otherPlatform.fallbackUrl = URL(string: "https://www.time.stream")
        linkBuilder?.otherPlatformParameters = otherPlatform

        linkBuilder?.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        linkBuilder?.socialMetaTagParameters?.title = title
        linkBuilder?.socialMetaTagParameters?.descriptionText = description
        if let str = imageURL {
            linkBuilder?.socialMetaTagParameters?.imageURL = URL(string: str)
        }

        linkBuilder?.navigationInfoParameters = DynamicLinkNavigationInfoParameters()
        linkBuilder?.navigationInfoParameters?.isForcedRedirectEnabled = true
        
        guard let longDynamicLink = linkBuilder?.url else {
            completion(nil)
            return
        }

        linkBuilder?.shorten(completion: { (url, value, error) in
            if error != nil {
                completion(longDynamicLink.absoluteURL)
            } else {
                completion(url)
            }
        })
    }
}
