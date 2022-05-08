//
//  GroupResultTableViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/19.
//

import UIKit

class GroupResultTableViewCell: UITableViewCell {

    @IBOutlet weak var mainImageView: UIImageView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var aurthorNameLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var dateIcon: UIImageView!
    
    @IBOutlet weak var membersIcon: UIImageView!
    
    @IBOutlet weak var membersLabel: UILabel!
    
    @IBOutlet weak var categoryLabel: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.borderColor = UIColor.systemGray6.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = .myBeige
        dateIcon.tintColor = .myDarkGreen
        membersIcon.tintColor = .myDarkGreen
        categoryLabel.isEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.height/2
        avatarImageView.clipsToBounds = true
        categoryLabel.layer.borderWidth = 1
        categoryLabel.layer.shadowColor = UIColor.myBrown.cgColor
        categoryLabel.titleLabel?.textColor = .myBrown
        categoryLabel.titleLabel?.font = UIFont(name: "PingFangTC-Semibold", size: 14)
        categoryLabel.layer.cornerRadius = 10
    }
    
}
