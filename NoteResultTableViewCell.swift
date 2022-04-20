//
//  SearchContentTableViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/17.
//

import UIKit

class NoteResultTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var mainImageView: UIImageView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var aurthorNameLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.height/2
        avatarImageView.clipsToBounds = true
    }
    
}
