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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dateIcon.image = UIImage(systemName: "calendar")
        dateIcon.tintColor = .myDarkGreen
        dateLabel.font =  UIFont(name: "PingFangTC-Semibold", size: 14)
        contentLabel.font =  UIFont(name: "PingFangTC-Regular", size: 14)
        durationLabel.font = UIFont(name: "PingFangTC-Regular", size: 14)
    }
}
