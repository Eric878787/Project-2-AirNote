//
//  chatroomListTableViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/19.
//

import UIKit

class ChatRoomListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.borderColor = UIColor.systemGray6.cgColor
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.height/2
        avatarImageView.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
