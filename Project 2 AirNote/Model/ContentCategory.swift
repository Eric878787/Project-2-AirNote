//
//  ProfileInfoCategory.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/5/17.
//

import Foundation
import UIKit

enum ContentCategory: String {
    
    case ownedNote = "我的筆記"
    
    case savedNote = "收藏筆記"
    
    case ownedGroup = "我的讀書會"
    
    case savedGroup = "加入讀書會"
    
    func identifier() -> String {

        switch self {

        case .ownedNote, .savedNote: return String(describing: PersonalNoteTableViewCell.self)
            
        case .ownedGroup, .savedGroup:  return String(describing: PersonalGroupTableViewCell.self)

        }
    }
    
    func cellForIndexPath(_ indexPath: IndexPath, _ tableView: UITableView, _ notes: [Note], _ groups: [Group], _ users: [User]) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier(), for: indexPath)
        
        switch self {
            
        case .ownedNote, .savedNote:
            
            guard let noteCell = cell as? PersonalNoteTableViewCell else { return cell }
            
            noteCell.layoutCell(notes, users, indexPath)
            
            return noteCell
            
        case .ownedGroup, .savedGroup:
            
            guard let groupCell = cell as? PersonalGroupTableViewCell else { return cell }
            
            groupCell.layoutCell(groups, users, indexPath)
            
            return groupCell
            
        }
        
    }
    
}
