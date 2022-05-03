//
//  NoteCarouselCollectionViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/22.
//

import UIKit

class NoteCarouselCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifer = "NoteCarouselCollectionViewCell"
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

extension NoteCarouselCollectionViewCell {
    func configure() {
        contentView.backgroundColor = .systemGray2
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.layer.cornerRadius = 10
        contentContainer.clipsToBounds = true
        
        contentView.addSubview(photoView)
        contentView.addSubview(contentContainer)
        
        photoView.translatesAutoresizingMaskIntoConstraints = false
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
