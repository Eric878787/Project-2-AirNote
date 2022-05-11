//
//  PersonalGroupTableViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/30.
//

import UIKit

class PersonalGroupTableViewCell: UITableViewCell {
    
    @IBOutlet weak var coverImage: UIImageView!
    
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var dateIcon: UIImageView!
    
    @IBOutlet weak var membersIcon: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var memberCountsLabel: UILabel!
    
    @IBOutlet weak var categoryButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.borderColor = UIColor.systemGray6.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = .myBeige
        dateIcon.tintColor = .myDarkGreen
        membersIcon.tintColor = .myDarkGreen
        categoryButton.isEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        avatarImage.layer.cornerRadius = avatarImage.bounds.height/2
        avatarImage.clipsToBounds = true
        categoryButton.layer.borderWidth = 1
        categoryButton.layer.shadowColor = UIColor.myBrown.cgColor
        categoryButton.titleLabel?.textColor = .myBrown
        categoryButton.titleLabel?.font = UIFont(name: "PingFangTC-Semibold", size: 12)
        categoryButton.layer.cornerRadius = 10
    }
    
}
