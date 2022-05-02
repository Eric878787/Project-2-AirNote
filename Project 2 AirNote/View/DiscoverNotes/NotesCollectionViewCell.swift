//
//  DiscoverNotesCollectionViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/10.
//

import UIKit

protocol NoteCollectionDelegate {
    
    func saveNote(_ selectedCell: NotesCollectionViewCell)
    
}

class NotesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var coverImage: UIImageView!
    
    @IBOutlet weak var userAvatarImage: UIImageView!
    
    @IBOutlet weak var authorNameLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var heartButton: UIButton!
    
    var delegate: NoteCollectionDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.borderColor = UIColor.systemGray6.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 10
        heartButton.tintColor = .myDarkGreen
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userAvatarImage.layer.cornerRadius = userAvatarImage.bounds.height/2
        userAvatarImage.clipsToBounds = true
    }
    
    @IBAction func likeAction(_ sender: Any) {
        
        delegate?.saveNote(self)
        
    }
}
