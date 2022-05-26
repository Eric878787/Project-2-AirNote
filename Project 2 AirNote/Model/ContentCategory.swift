//
//  ProfileInfoCategory.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/5/17.
//

import Foundation
import UIKit

enum NoteCategory: Int, CaseIterable {
    
    case ownedNote = 0
    
    case savedNote = 1
    
    func title() -> String {
        
        switch self {
            
        case.ownedNote: return "我的筆記"
            
        case.savedNote: return "收藏筆記"
            
        }
    }
    
    func identifier() -> String {

        switch self {

        case .ownedNote, .savedNote: return String(describing: PersonalNoteTableViewCell.self)

        }
    }
    
    func cellForIndexPath(_ indexPath: IndexPath, _ tableView: UITableView, _ notes: [Note] = [], _ users: [User] = []) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier(), for: indexPath)
        
        switch self {
            
        case .ownedNote, .savedNote:
            
            guard let noteCell = cell as? PersonalNoteTableViewCell else { return cell }
            
            noteCell.layoutCell(notes, users, indexPath)
            
            return noteCell
            
        }
        
    }
    
}

enum GroupCategory: Int, CaseIterable {
    
    case ownedGroup = 0
    
    case savedGroup = 1
    
    func title() -> String {
        
        switch self {
            
        case.ownedGroup: return "我的讀書會"
            
        case.savedGroup: return "收藏讀書會"
            
        }
    }
    
    func identifier() -> String {

        switch self {
            
        case .ownedGroup, .savedGroup:  return String(describing: PersonalGroupTableViewCell.self)

        }
    }
    
    func cellForIndexPath(_ indexPath: IndexPath, _ tableView: UITableView, _ groups: [Group] = [], _ users: [User] = []) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier(), for: indexPath)
        
        switch self {
            
        case .ownedGroup, .savedGroup:
            
            guard let groupCell = cell as? PersonalGroupTableViewCell else { return cell }
            
            groupCell.layoutCell(groups, users, indexPath)
            
            return groupCell
            
        }
        
    }
    
}
