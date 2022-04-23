//
//  ChatRoomDataModel.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/20.
//

import Foundation

struct ChatRoom: Codable {
    var chatRoomId: String
    var groupId: String
    var messages: [Message]
    var roomTitle: String
    var ownerId: String
    var createdTime: Date
}

struct Message: Codable, Equatable {
    var sender: String
    var createdTime: Date
    var content: String?
    var image: String?
}
