//
//  NoteTitleCollectionViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/22.
//

import UIKit

class NoteTitleCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifer = "NoteTitleCollectionViewCell"
    
    @IBOutlet weak var viewsIcon: UIImageView!
    
    @IBOutlet weak var viewsLabel: UILabel!
    
    @IBOutlet weak var commentCountsIcon: UIImageView!
    
    @IBOutlet weak var commentCountsLabel: UILabel!
    
    @IBOutlet weak var likeIcon: UIImageView!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = .systemGray2
        viewsIcon.image = UIImage(systemName: "eye")
        commentCountsIcon.image = UIImage(systemName: "message")
    }
    
}
