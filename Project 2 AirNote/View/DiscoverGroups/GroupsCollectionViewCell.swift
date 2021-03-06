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
    
    @IBOutlet weak var dateIcon: UIImageView!
    
    @IBOutlet weak var membersIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.borderColor = UIColor.systemGray6.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = .myBeige
        dateIcon.tintColor = .myDarkGreen
        membersIcon.tintColor = .myDarkGreen
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userAvatar.layer.cornerRadius = userAvatar.bounds.height/2
        userAvatar.clipsToBounds = true
        coverImage.clipsToBounds = true
        coverImage.layer.cornerRadius = 10
    }

}
