//
//  GroupTitleCollectionViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/23.
//

import UIKit

class GroupTitleCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifer = "GroupTitleCollectionViewCell"
    
    @IBOutlet weak var locationIcon: UIImageView!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var dateIcon: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var applyButton: UIButton!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = .systemGray2
        locationIcon.image = UIImage(systemName: "mappin.and.ellipse")
        dateIcon.image = UIImage(systemName: "calendar")
        applyButton.setTitle("加入", for: .normal)
        applyButton.setTitleColor( .black, for: .selected)
        applyButton.backgroundColor = .systemGray2
        applyButton.layer.cornerRadius = 10
        applyButton.clipsToBounds = true
    }
    
}
