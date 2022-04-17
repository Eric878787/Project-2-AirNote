//
//  NotesDataModel.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/12.
//

import Foundation

struct Note: Codable {
    
    var authorId: String
    var comments: [Comment]
    var createdTime: Date
    var likes: [String]
    var noteCategory: String
    var noteClicks: [String]
    var noteContent: String
    var noteCover: String
    var noteId: String
    var noteImages: [String]
    var noteKeywords: [String]
    var noteTitle: String
    
    var userName: String?
    var userAvatar: String?
    
}

struct Comment: Codable {
    
    var content: String
    var createdTime: Date
    var userId: String
    
}
