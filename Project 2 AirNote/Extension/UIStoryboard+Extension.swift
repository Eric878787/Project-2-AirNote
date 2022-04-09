//
//  UIStoryboard+Extension.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/9.
//

import UIKit

private struct StoryboardCategory {

    static let main = "Main"

    static let discoverNotes = "DiscoverNotes"
}

extension UIStoryboard {

    static var main: UIStoryboard { return Storyboard(name: StoryboardCategory.main) }

    static var discoverNotes: UIStoryboard { return Storyboard(name: StoryboardCategory.discoverNotes) }

    private static func Storyboard(name: String) -> UIStoryboard {

        return UIStoryboard(name: name, bundle: nil)
    }
}

