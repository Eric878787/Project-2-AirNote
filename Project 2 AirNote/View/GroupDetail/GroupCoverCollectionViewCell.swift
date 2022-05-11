//
//  GroupCoverCollectionViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/23.
//

import UIKit

class GroupCoverCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifer = "GroupCoverCollectionViewCell"
    let photoView = UIImageView()
    let contentContainer = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GroupCoverCollectionViewCell {
    func configure() {
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentContainer)
        
        photoView.translatesAutoresizingMaskIntoConstraints = false
        photoView.layer.borderWidth = 1
        photoView.layer.borderColor = UIColor.systemGray6.cgColor
        photoView.layer.cornerRadius = 5
        photoView.contentMode = .scaleAspectFill
        contentContainer.addSubview(photoView)
        
        NSLayoutConstraint.activate([
            contentContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            photoView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 10),
            photoView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -10),
            photoView.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 10),
            photoView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: -10)
        ])
    }
}
