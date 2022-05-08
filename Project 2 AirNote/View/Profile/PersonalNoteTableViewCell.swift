//
//  SavedNoteTableViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/24.
//

import UIKit

class PersonalNoteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mainImageView: UIImageView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var categoryButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.borderColor = UIColor.systemGray6.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = .myBeige
        categoryButton.isEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.height/2
        avatarImageView.clipsToBounds = true
        mainImageView.clipsToBounds = true
        mainImageView.layer.cornerRadius = 10
        categoryButton.layer.borderWidth = 1
        categoryButton.layer.borderColor = UIColor.myBrown.cgColor
        categoryButton.titleLabel?.textColor = .myBrown
        categoryButton.titleLabel?.font = UIFont(name: "PingFangTC-Semibold", size: 14)
        categoryButton.layer.cornerRadius = 10
    }
    
}
