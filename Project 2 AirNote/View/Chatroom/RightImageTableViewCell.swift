//
//  RightImageTableViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/5/11.
//

import UIKit

class RightImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageImage: UIImageView!
    
    @IBOutlet weak var createdTimeLabel: UILabel!
    
    var imageHandler: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        messageImage.isUserInteractionEnabled = true
        messageImage.addGestureRecognizer(tapGestureRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        messageImage.layer.cornerRadius = 10
        messageImage.clipsToBounds = true
    }
    
    @objc private func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        
        imageHandler?()
        
    }
    
}
