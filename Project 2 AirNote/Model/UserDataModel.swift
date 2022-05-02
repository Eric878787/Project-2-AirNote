//
//  UsersDataModel.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/12.
//

import Foundation

struct User: Codable {
    var chatRooms: [String]
    var followers: [String]
    var followings: [String]
    var joinedGroups: [String]
    var savedNotes: [String]
    var userAvatar: String
    var userGroups: [String]
    var userName: String
    var userNotes: [String]
    var email: String?
    var uid: String
}
