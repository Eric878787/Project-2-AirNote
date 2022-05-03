//
//  AppDelegate.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/8.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true
        
        FirebaseManager.shared.authenticator.addStateDidChangeListener { auth, user in
            if let user = user {
                print("\(user.uid) login")
                FirebaseManager.shared.currentUser = user
            } else {
                print("not login")
                FirebaseManager.shared.currentUser = user
            }
        }
        
        // Navigatiob Bar Item Color
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.tintColor = UIColor.myDarkGreen
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor :  UIColor.myDarkGreen]
        
        // Tab Bar color
        UITabBar.appearance().tintColor = UIColor.myDarkGreen
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
