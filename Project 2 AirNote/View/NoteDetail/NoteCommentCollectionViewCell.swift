//
//  NoteCommentCollectionViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/23.
//

import UIKit

class NoteCommentCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var commentTimeLabel: UILabel!
    
    var commentTouchHandler: (() -> Void)?
    
    static let reuseIdentifer = "NoteCommentCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTapGesture()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        contentView.backgroundColor = .systemGray2
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
    }
    
    func addTapGesture() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        let tapImageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapImageGestureRecognizer)
        nameLabel.isUserInteractionEnabled = true
        nameLabel.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        print("1111111")
        commentTouchHandler?()
    }
    
}
