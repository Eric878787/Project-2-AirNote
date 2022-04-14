//
//  DiscoverNotesCollectionViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/10.
//

import UIKit

class NotesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var likeLabel: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
