//
//  CategoryCollectionViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/11.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        categoryView.layer.cornerRadius = 10
        categoryView.backgroundColor = .white
        categoryView.layer.borderColor = UIColor.myDarkGreen.cgColor
        categoryView.layer.borderWidth = 1
        categoryLabel.textColor = .white
        categoryLabel.font = UIFont(name: "PingFangTC-Semibold", size: 14)
    }
    
}
