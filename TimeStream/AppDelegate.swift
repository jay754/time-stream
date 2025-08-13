//
//  AppDelegate.swift
//  TimeStream
//
//  Created  on 03.07.2021.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import AVKit
import EggRating
import Stripe
import Kingfisher
import Adyen

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    private let userDefaultsHelper = UserDefaultsHelper()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        FirebaseApp.configure()
        
        AppearanceHelper.configureNavigationBar()
        AppearanceHelper.configureTabBar()
        #if DEBUG
        Auth.auth().settings?.isAppVerificationDisabledForTesting = true
        #endif
        
        // TODO: Change this
        EggRating.itunesId = "1607803576"
        EggRating.minRatingToAppStore = 3.5
        
//        StripeAPI.defaultPublishableKey = UserDefinedSettings.valueFor(.STRIPE_KEY)

//        StripeAPI.defaultPublishableKey = "pk_test_51Ic6ZpKZ3arTVa2lfwnsX49LxGmL4ey9PdRNS8Je9eqEoIXWU5gut1mHpsb6h9FzDS5QFmoTeNDj3xdrkFH2nj0Q00OFdN2zhG"
        
//        StripeAPI.defaultPublishableKey = "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"
        
        ImageCache.default.diskStorage.config.expiration = .never
        ImageCache.default.memoryStorage.config.totalCostLimit = 200 * 1024 * 1024 // 200mb
        ImageCache.default.diskStorage.config.sizeLimit = 1000 * 1024 * 1024 // 1gb
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        
        registerForPushNotifications(application: application)
        print("FCM token: \(PushNotificationsManager.instance.pushNotificationsToken)")
        

//        // Disable category selection on oboarding
//        if userDefaultsHelper.getCategories() == nil {
//            userDefaultsHelper.set(categories: Category.allCategories)
//        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    // MARK: Push notifications
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        PushNotificationsManager.instance.handlePushNotification(userInfo: userInfo)
        
        completionHandler()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().setAPNSToken(deviceToken, type: MessagingAPNSTokenType.prod)
        Auth.auth().setAPNSToken(deviceToken, type: .unknown) // Setting this to .unknown is what seems to have helped
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        RedirectComponent.applicationDidOpen(from: url)
        return true
    }
    
    // MARK: Private methods
    
    private func registerForPushNotifications(application: UIApplication) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
          )
        

        application.registerForRemoteNotifications()
    }
    

}

