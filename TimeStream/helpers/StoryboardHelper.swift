//
//  StoryboardHelper.swift
//  FlexiPass
//
//  Created by appssemble on 12.05.2021.
//

import UIKit

enum StoryboardName: String {
    case Authentication
    case Onboarding
    case Home
    case Inbox
    case Explore
    case Profile
    case New
    case Misc
}

class StoryboardHelper {
    
    static func viewControllerFromStoryboard(name: StoryboardName, identifier:String) -> UIViewController {
        let storyboard = UIStoryboard(name: name.rawValue, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
        
        return viewController
    }
}
