//
//  MainFlowManager.swift
//  TimeStream
//
//  Created on 03.07.2021.
//

import UIKit
import Kingfisher

class MainFlowManager: BaseFlowManager {
    
    // Nav Controllers
    private let homeNavController = UINavigationController()
    private let exploreNavController = UINavigationController()
    private let inboxNavController = UINavigationController()
    private let profileNavController = UINavigationController()
    private let newNavController = UINavigationController()
    
    // Flows
    private var homeFlow: HomeFlowManager!
    private var exploreFlow: ExploreFlowManager!
    private var inboxFlow: InboxFlowManager!
    private var profileFlow: ProfileFlowManager!
    private var newFlow: NewFlowManager!
    
    // Tab bar
    private let tabViewController = TabBarViewController()
    private let dummyAddController = UIViewController()
    
    private let authNavController = UINavigationController()
    private var authenticationFlow: AuthenticationFlowManager!
    
    override init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
        
        tabViewController.authenticationDelegate = self
        
        homeFlow = HomeFlowManager(navigationController: homeNavController)
        exploreFlow = ExploreFlowManager(navigationController: exploreNavController)
        profileFlow = ProfileFlowManager(navigationController: profileNavController)
        inboxFlow = InboxFlowManager(navigationController: inboxNavController)
        newFlow = NewFlowManager(navigationController: newNavController)
        authenticationFlow = AuthenticationFlowManager(navigationController: authNavController, overlay: true)
        
        homeFlow.delegate = self
        exploreFlow.delegate = self
        profileFlow.delegate = self
        inboxFlow.delegate = self
        newFlow.delegate = self
        authenticationFlow.delegate = self
        
        homeFlow.actionsDelegate = self
        profileFlow.actionsDelegate = self
        
        profileNavController.hidesBottomBarWhenPushed = true
        
        LocalNotifications.addObserver(item: self, selector: #selector(setProfileImage), type: .userChanged)
    }
    
    override func startFlow() {
        super.startFlow()
        shouldReplaceNavigationStack = true
        navigationController.navigationBar.isHidden = true
        
        startFlows()
        configureTabs()
        handleColor()
        
        navigationController.viewControllers = [tabViewController]
    }
    
    override func setDelegates(for viewController: UIViewController) {

    }
    
    // MARK: Private methods
    
    private func configureTabs() {
        
        let insets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)

        let exploreSelected = UIImage(named: "explore-selected")?.activeTabBarImage()
        let explore = UIImage(named: "explore")?.inactiveTabBarImage()
        
        let profileSelected = UIImage(named: "profile-selected")?.activeTabBarImageSmall()
        let profile = UIImage(named: "profile")?.inactiveTabBarImageSmall()
        
        let homeSelected = UIImage(named: "home-selected")?.activeTabBarImage()
        let home = UIImage(named: "home")?.inactiveTabBarImage()
        
        let newSelected = UIImage(named: "new-selected")?.activeTabBarImage()
        let new = UIImage(named: "new")?.inactiveTabBarImage()
        
        let inboxSelected = UIImage(named: "inbox-selected")?.activeTabBarImage()
        let inbox = UIImage(named: "inbox")?.inactiveTabBarImage()
        

        let homeItem = UITabBarItem(title: nil, image: home, selectedImage: homeSelected)
        homeNavController.tabBarItem = homeItem
        homeNavController.tabBarItem.imageInsets = insets
        
        let exploreItem = UITabBarItem(title: nil, image: explore, selectedImage: exploreSelected)
        exploreNavController.tabBarItem = exploreItem
        exploreNavController.tabBarItem.imageInsets = insets
        
        let inboxItem = UITabBarItem(title: nil, image: inbox, selectedImage: inboxSelected)
        inboxNavController.tabBarItem = inboxItem
        inboxNavController.tabBarItem.imageInsets = insets
        inboxNavController.title = nil
        
        let profileItem = UITabBarItem(title: nil, image: profile, selectedImage: profileSelected)
        profileNavController.tabBarItem = profileItem
        profileNavController.tabBarItem.imageInsets = insets
        
        let newItem = UITabBarItem(title: nil, image: new, selectedImage: newSelected)
        dummyAddController.tabBarItem = newItem
        dummyAddController.tabBarItem.imageInsets = insets
        
        tabViewController.viewControllers = [homeNavController, exploreNavController, dummyAddController, inboxNavController, profileNavController]
        
        tabViewController.selectedIndex = 4
    }
    
    private func startFlows() {
        homeFlow.startFlow()
        exploreFlow.startFlow()
        inboxFlow.startFlow()
        profileFlow.startFlow()
        
        setProfileImage()
    }
    
    // MARK: Private methods
    
    private func handleLoginAndDoAction(action: @escaping EmptyClosure) {
        authenticationFlow.authenticateIfNeededAndDoAction(from: navigationController) { _ in
            action()
        }
    }
    
    @objc
    private func setProfileImage() {
        guard let url = Context.current.user?.photoURL else {
            let profileSelected = UIImage(named: "profile-selected")?.activeTabBarImageSmall()
            let profile = UIImage(named: "profile")?.inactiveTabBarImageSmall()
    
            profileNavController.tabBarItem = UITabBarItem(title: nil, image: profile, selectedImage: profileSelected)
            profileNavController.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            
            // user is not authenticated
            return
        }
        
        KingfisherManager.shared.retrieveImage(with: url) { (result) in
            switch result {
            case .success(let image):
                if let image2 = image.image.resizeImage(targetWidth: 25) {
                    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
                    imageView.clipsToBounds = true
                    imageView.image = image2.withRenderingMode(.alwaysOriginal)
                    imageView.layer.cornerRadius = 12.5
                    imageView.contentMode = .scaleAspectFill
                    imageView.layer.borderWidth = self.tabViewController.selectedIndex == 4 ? 2 : 0
                    imageView.layer.borderColor = UIColor.accent.cgColor
                    
                    let circleImage = imageView.asImage().withRenderingMode(.alwaysOriginal)
                    
                    self.profileNavController.tabBarItem = UITabBarItem(title: nil, image: circleImage, selectedImage: circleImage)
                    self.profileNavController.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
                }
            case .failure(_):
                break
            }
        }
    }
}

extension MainFlowManager: BaseFlowDelegate {
    func flowDidStart(flow: BaseFlowManager) {
        
    }
    
    func flowDidFinish(flow: BaseFlowManager) {
        if flow === profileFlow {
            handleLogOut()
        }
        
        if flow === authenticationFlow || flow === newFlow {
            navigationController.dismiss(animated: true, completion: nil)
        }
    }
    
    func flowDidCancel(flow: BaseFlowManager) {
        if flow === newFlow {
            navigationController.dismiss(animated: true, completion: nil)
        }
    }
    
    private func handleLogOut() {
        clearNavControllers()
//        startFlow()
//        tabViewController.selectedIndex = 1
//        tabViewController.view.backgroundColor = UIColor.white
//        tabViewController.tabBar.barTintColor = UIColor.white
        
        delegate?.flowDidFinish(flow: self)
    }
    
    private func clearNavControllers() {
        homeNavController.viewControllers = []
        exploreNavController.viewControllers = []
        profileNavController.viewControllers = []
        inboxNavController.viewControllers = []
        newNavController.viewControllers = []
    }
}

extension MainFlowManager: TabBarViewControllerDelegate {
    
    private func startNewFlow() {
        newFlow.startFlow()
        newNavController.modalPresentationStyle = .overFullScreen
        navigationController.present(newNavController, animated: false, completion: nil)
        
        LocalNotifications.issueNotification(type: .pausePlayingVideo)
    }
    
    func shouldSelectTab(viewController: UIViewController) -> Bool {
        if viewController === dummyAddController {
            handleLoginAndDoAction {
                // Start the new flow if the user is logged in
                self.startNewFlow()
            }

            return false
        }
        
        if viewController === exploreNavController {
            LocalNotifications.issueNotification(type: .willMoveToExplorePage)
            
            return true
        }

        if Context.current.authenticated {
            if viewController === profileNavController {
                tabViewController.view.backgroundColor = UIColor.backgroundColor
                tabViewController.tabBar.barTintColor = UIColor.backgroundColor
            } else {
                tabViewController.tabBar.barTintColor = UIColor.white
                tabViewController.view.backgroundColor = UIColor.white
            }

            // user is authenticated
            return true
        }

        if viewController === profileNavController {
            handleLoginAndDoAction {
                // Do nothing
                self.tabViewController.view.backgroundColor = UIColor.backgroundColor
                self.tabViewController.tabBar.barTintColor = UIColor.backgroundColor
                self.tabViewController.selectedIndex = 4
            }

            return false
        }
        
        if viewController === homeNavController {
            handleLoginAndDoAction {
                // Do nothing
                self.tabViewController.selectedIndex = 0
            }

            return false
        }
        
        if viewController === inboxNavController {
            handleLoginAndDoAction {
                // Do nothing
                self.tabViewController.selectedIndex = 3
            }

            return false
        }
        
        return true
    }
    
    func changedTabBarItem(viewController: UIViewController) {
        setProfileImage()
        handleColor()
    }
    
    private func handleColor() {
        if tabViewController.selectedIndex == 4 {
            tabViewController.view.backgroundColor = UIColor.backgroundColor
            tabViewController.tabBar.barTintColor = UIColor.backgroundColor
        } else {
            tabViewController.tabBar.barTintColor = UIColor.white
            tabViewController.view.backgroundColor = UIColor.white
        }
    }
}

extension MainFlowManager: ProfileFlowActionsDelegate {
    func profileGoToActivity(flow: ProfileFlowManager) {
        tabViewController.selectedIndex = 3
        tabViewController.view.backgroundColor = UIColor.white
        tabViewController.tabBar.barTintColor = UIColor.white
    }
    
    func profileChangePhoneNumber(flow: ProfileFlowManager) {
        authenticationFlow.startChangePhoneNumber()

        authNavController.modalPresentationStyle = .overFullScreen
        navigationController.present(authNavController, animated: true, completion: nil)
    }
}

extension MainFlowManager: HomeFlowActionsDelegate {
    
    func homeFlowGoToExploreCategory(flow: HomeFlowManager, category: Category) {
        exploreFlow.startFlow(category: category)
        tabViewController.selectedIndex = 1
    }
}
