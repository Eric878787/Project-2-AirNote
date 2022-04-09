//
//  ViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/8.
//

import UIKit

private enum Tab {

    case discoverNotes

    func controller() -> UIViewController {

        var controller: UIViewController

        switch self {

        case .discoverNotes: controller = UIStoryboard.discoverNotes.instantiateInitialViewController()!

        }

        controller.tabBarItem = tabBarItem()

        controller.tabBarItem.imageInsets = UIEdgeInsets(top: 6.0, left: 0.0, bottom: -6.0, right: 0.0)

        return controller
    }

    func tabBarItem() -> UITabBarItem {

        switch self {

        case .discoverNotes:
            return UITabBarItem(
                // To be changed into enum of UIImage
                title: "探索筆記",
                image: nil,
                selectedImage: nil
            )
        }
    }
}

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    private let tabs: [Tab] = [.discoverNotes]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = tabs.map({ $0.controller() })
        
        delegate = self
        
    }


}

