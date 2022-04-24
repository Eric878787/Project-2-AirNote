//
//  GroupCalendarCollectionViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/23.
//

import UIKit

class GroupCalendarCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dateIcon: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    static let reuseIdentifer = "GroupCalendarCollectionViewCell"
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        dateIcon.image = UIImage(systemName: "calendar")
        
        super.layoutSubviews()
        contentView.backgroundColor = .systemGray2
    }
}
