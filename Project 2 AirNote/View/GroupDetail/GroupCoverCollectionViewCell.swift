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
        contentView.backgroundColor = .systemGray2
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(photoView)
        contentView.addSubview(contentContainer)
        
        photoView.translatesAutoresizingMaskIntoConstraints = false
        photoView.layer.cornerRadius = 4
        photoView.clipsToBounds = true
        contentContainer.addSubview(photoView)
        
        NSLayoutConstraint.activate([
            contentContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            photoView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            photoView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            photoView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            photoView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)
        ])
    }
}
