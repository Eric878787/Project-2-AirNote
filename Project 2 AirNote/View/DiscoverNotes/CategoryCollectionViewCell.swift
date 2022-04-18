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
        categoryView.layer.borderColor = UIColor.clear.cgColor
        categoryView.layer.borderWidth = 1
        categoryView.backgroundColor = .systemGray6
        categoryLabel.textColor = .systemGray2
        categoryLabel.font = UIFont(name: "PingFangTC-Regular", size: 11)
    }
    
}
