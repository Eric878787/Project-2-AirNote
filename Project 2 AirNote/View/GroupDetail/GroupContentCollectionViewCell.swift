//
//  GroupContentCollectionViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/23.
//

import UIKit

class GroupContentCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifer = "GroupContentCollectionViewCell"
    let contentLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension GroupContentCollectionViewCell {
 
    func configure() {
        contentLabel.numberOfLines = 0
        contentLabel.font = UIFont(name: "PingFangTC-Semibold", size: 14)
        contentView.addSubview(contentLabel)
        
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
        ])
    }
    
}
