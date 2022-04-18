//
//  GroupsCollectionViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/18.
//

import UIKit

class GroupsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var coverImage: UIImageView!
    
    @IBOutlet weak var userAvatar: UIImageView!
    
    @IBOutlet weak var authorNameLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var memberCountsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
