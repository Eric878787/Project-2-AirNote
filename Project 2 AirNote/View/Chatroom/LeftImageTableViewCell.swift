//
//  LeftImageTableViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/5/11.
//

import UIKit

class LeftImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageImage: UIImageView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var createdTimeLabel: UILabel!
    
    var imageHandler: (() -> Void)?
    
    var avatarHandler: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        messageImage.isUserInteractionEnabled = true
        messageImage.addGestureRecognizer(tapGestureRecognizer)
        
        let tapAvatarGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(avatarImageTapped(tapGestureRecognizer:)))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapAvatarGestureRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        messageImage.layer.cornerRadius = 10
        messageImage.clipsToBounds = true
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        
    }
    
    @objc private func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        
        imageHandler?()
        
    }
    
    @objc private func avatarImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        
        avatarHandler?()
        
    }
    
}
