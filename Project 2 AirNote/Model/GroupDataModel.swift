//
//  GroupDataModel.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/18.
//

import Foundation

struct Group: Codable {
    var schedules: [Schedule]
    var createdTime: Date
    var groupCategory: String
    var groupKeywords: [String]
    var groupContent: String
    var groupCover: String
    var groupId: String
    var groupMembers: [String]
    var groupOwner: String
    var groupTitle: String
    var location: Location
    var messages: [Message]
}

struct Schedule: Codable {
    var date: Date
    var title: String
}

struct Location: Codable {
    var address: String
    var latitude: Double
    var longitude: Double
}

struct Message: Codable, Equatable {
    var sender: String
    var createdTime: Date
    var content: String?
    var image: String?
}
