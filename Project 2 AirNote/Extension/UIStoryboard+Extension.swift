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
    
    static let discoverStudyGroups = "DiscoverStudyGroups"
    
    static let addContent = "AddContent"
    
    static let chatroomLobby = "ChatroomLobby"
    
    static let profile = "Profile"
}

extension UIStoryboard {

    static var main: UIStoryboard { return storyboard(name: StoryboardCategory.main) }

    static var discoverNotes: UIStoryboard { return storyboard(name: StoryboardCategory.discoverNotes) }
    
    static var discoverStudyGroups: UIStoryboard { return storyboard(name: StoryboardCategory.discoverStudyGroups) }
    
    static var addContent: UIStoryboard { return storyboard(name: StoryboardCategory.addContent)}
    
    static var chatroomLobby: UIStoryboard { return storyboard(name: StoryboardCategory.chatroomLobby) }
    
    static var profile: UIStoryboard { return storyboard(name: StoryboardCategory.profile) }
    
    private static func storyboard(name: String) -> UIStoryboard {

        return UIStoryboard(name: name, bundle: nil)
    }
}
