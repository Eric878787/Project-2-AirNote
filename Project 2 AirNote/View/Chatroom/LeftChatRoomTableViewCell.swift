//
//  ChatRoomTableViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/20.
//

import UIKit

class LeftChatRoomTableViewCell: UITableViewCell {
    
   
    @IBOutlet weak var leftBackgroundView: UIView!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var messageImage: UIImageView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        leftBackgroundView.backgroundColor = .systemGray6
        leftBackgroundView.clipsToBounds = true
        leftBackgroundView.layer.cornerRadius = 10
        
        messageImage.layer.cornerRadius = 10
        messageImage.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
