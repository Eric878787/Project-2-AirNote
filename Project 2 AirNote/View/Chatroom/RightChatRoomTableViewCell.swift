//
//  RightChatRoomTableView.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/20.
//

import UIKit

class RightChatRoomTableViewCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var rightBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rightBackgroundView.backgroundColor = .systemBlue
        rightBackgroundView.clipsToBounds = true
        rightBackgroundView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
