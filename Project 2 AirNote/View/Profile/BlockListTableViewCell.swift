//
//  BlockListTableViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/5/4.
//

import UIKit

protocol BlockListDelegate {
    
    func unblockUser(_ didselect: BlockListTableViewCell)
    
}

class BlockListTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: BlockListTableViewCell.self)

    @IBOutlet weak var userAvatar: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var unblockButton: UIButton!
    
    var delegate: BlockListDelegate?
    
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
        
        // User Avatar
        userAvatar.layer.cornerRadius = userAvatar.bounds.height/2
        userAvatar.clipsToBounds = true

        // UserName
        userName.font = UIFont(name: "PingFangTC-Regular", size: 16)
        userName.textColor = .black

        // Unblock button
        unblockButton.setTitle("解除封鎖", for: .normal)
        unblockButton.setTitleColor(.white, for: .normal)
        unblockButton.backgroundColor = .myDarkGreen
        unblockButton.layer.cornerRadius = 10
        unblockButton.clipsToBounds = true
    }
    
    @IBAction func unblockUser(_ sender: Any) {
        
        delegate?.unblockUser(self)
        
    }
}
