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
    var category: String
    var clicks: [String]
    var content: String
    var cover: String
    var noteId: String
    var images: [String]
    var keywords: [String]
    var title: String
}

struct Comment: Codable, Equatable {
    
    var content: String
    var createdTime: Date
    var uid: String
    
}
