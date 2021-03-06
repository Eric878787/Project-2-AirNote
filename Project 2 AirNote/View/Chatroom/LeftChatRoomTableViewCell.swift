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
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var createdTimeLabel: UILabel!
    
    var avatarHandler: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        
        let tapAvatarGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(avatarImageTapped(tapGestureRecognizer:)))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapAvatarGestureRecognizer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        leftBackgroundView.backgroundColor = .systemGray6
        leftBackgroundView.clipsToBounds = true
        leftBackgroundView.layer.cornerRadius = 10
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc private func avatarImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        
        avatarHandler?()
        
    }
    
}
