//
//  ViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/8.
//

import UIKit

private enum Tab {
    
    case discoverNotes
    
    case discoverStudyGroups
    
    case chatroomLobby
    
    case profile
    
    func controller() -> UIViewController {
        
        var controller: UIViewController
        
        switch self {
            
        case .discoverNotes: controller = UIStoryboard.discoverNotes.instantiateInitialViewController()!
            
        case .discoverStudyGroups: controller = UIStoryboard.discoverStudyGroups.instantiateInitialViewController()!
            
        case.chatroomLobby: controller = UIStoryboard.chatroomLobby.instantiateInitialViewController()!
            
        case.profile: controller = UIStoryboard.profile.instantiateInitialViewController()!
        }
        
        controller.tabBarItem = tabBarItem()
        
        controller.tabBarItem.imageInsets = UIEdgeInsets(top: 6.0, left: 0.0, bottom: -6.0, right: 0.0)
        
        return controller
    }
    
    // MARK: To be changed into enum of UIImage
    func tabBarItem() -> UITabBarItem {
        
        switch self {
            
        case .discoverNotes:
            return UITabBarItem(
                title: "探索筆記",
                image: UIImage(systemName: "note.text"),
                selectedImage: nil
            )
            
        case .discoverStudyGroups:
            return UITabBarItem(
                title: "探索讀書會",
                image: UIImage(systemName: "person.2.fill"),
                selectedImage: nil
            )

        case.chatroomLobby:
            return UITabBarItem(
                title: "聊天室",
                image: UIImage(systemName: "message.fill"),
                selectedImage: nil
            )
            
        case.profile:
            return UITabBarItem(
                title: "個人",
                image: UIImage(systemName: "message.fill"),
                selectedImage: nil
            )
            
        }
    }
}

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    // MARK: Properties
    private let tabs: [Tab] = [.discoverNotes, .discoverStudyGroups, .chatroomLobby, .profile]
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = tabs.map({ $0.controller() })
        
        delegate = self
        
    }
    
    // MARK: Methods
    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {
        if FirebaseManager.shared.currentUser == nil {
            if let viewControllers = tabBarController.viewControllers {
                if viewController == viewControllers[2] || viewController == viewControllers[3] {
                    guard let viewController = UIStoryboard.auth.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return false }
                    viewController.modalPresentationStyle = .overCurrentContext
                    present(viewController, animated: false, completion: nil)
                    return false
                }
            }
            return true
        } else {
            return true
        }
    }
    
}
