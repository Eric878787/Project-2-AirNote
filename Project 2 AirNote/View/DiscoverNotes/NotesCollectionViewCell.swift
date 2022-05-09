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
        contentView.backgroundColor = .myBeige
        heartButton.tintColor = .myDarkGreen
        heartButton.contentMode = .scaleAspectFit
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userAvatarImage.clipsToBounds = true
        userAvatarImage.layer.cornerRadius = userAvatarImage.bounds.height/2
        coverImage.clipsToBounds = true
        coverImage.layer.cornerRadius = 10
    }
    
    @IBAction func likeAction(_ sender: Any) {
        
        delegate?.saveNote(self)
        
    }
}
