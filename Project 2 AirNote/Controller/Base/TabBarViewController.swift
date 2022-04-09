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

    func controller() -> UIViewController {

        var controller: UIViewController

        switch self {

        case .discoverNotes: controller = UIStoryboard.discoverNotes.instantiateInitialViewController()!
            
        case .discoverStudyGroups: controller = UIStoryboard.discoverStudyGroups.instantiateInitialViewController()!

        }

        controller.tabBarItem = tabBarItem()

        controller.tabBarItem.imageInsets = UIEdgeInsets(top: 6.0, left: 0.0, bottom: -6.0, right: 0.0)

        return controller
    }

    //MARK: To be changed into enum of UIImage
    func tabBarItem() -> UITabBarItem {

        switch self {

        case .discoverNotes:
            return UITabBarItem(
                title: "探索筆記",
                image: nil,
                selectedImage: nil
            )
            
        case .discoverStudyGroups:
            return UITabBarItem(
                title: "探索讀書會",
                image: nil,
                selectedImage: nil
            )
            
        }
    }
}

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    private let tabs: [Tab] = [.discoverNotes, .discoverStudyGroups]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = tabs.map({ $0.controller() })
        
        delegate = self
        
    }


}

