//
//  TitleHeaderView.swift
//  
//
//  Created by Eric chung on 2022/4/22.
//

import UIKit

protocol TitleSupplementaryViewDelegate {
    
    func didTouchellipsis()
    
}

class TitleSupplementaryView: UICollectionReusableView {
    static let reuseIdentifier = String(describing: TitleSupplementaryView.self)
    
    let textLabel = UILabel()
    
    let avatar = UIImageView()
    
    let name = UILabel()
    
    let timeLabel = UILabel()
    
    let blockButton = UIButton()
    
    var delegate: NoteTitleDelegate?
    
    var blockUserDelegate: TitleSupplementaryViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        addTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        configure()
        addTapGesture()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatar.clipsToBounds = true
        avatar.contentMode = .scaleAspectFill
        avatar.layer.cornerRadius = avatar.frame.height / 2
    }
    
    func configure() {
        addSubview(textLabel)
        addSubview(avatar)
        addSubview(name)
        addSubview(timeLabel)
        addSubview(blockButton)
        textLabel.font = UIFont(name: "PingFangTC-Semibold", size: 18)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = UIFont(name: "PingFangTC-Regular", size: 14)
        timeLabel.textColor = .gray
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        avatar.translatesAutoresizingMaskIntoConstraints = false
        name.translatesAutoresizingMaskIntoConstraints = false
        name.font = UIFont(name: "PingFangTC-Semibold", size: 14)
        blockButton.tintColor = .myDarkGreen
        blockButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        blockButton.addTarget(self, action: #selector(ellipsisToched), for: .touchUpInside)
        blockButton.translatesAutoresizingMaskIntoConstraints = false
        
        let inset: CGFloat = 0
        
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset),
            timeLabel.centerYAnchor.constraint(equalTo: textLabel.centerYAnchor, constant: -inset),
            timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            avatar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            avatar.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            avatar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset),
            avatar.widthAnchor.constraint(equalToConstant: 40),
            avatar.heightAnchor.constraint(equalToConstant: 40),
            name.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 5),
            name.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),
            name.trailingAnchor.constraint(equalTo: blockButton.leadingAnchor, constant: 5),
            blockButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            blockButton.centerYAnchor.constraint(equalTo: avatar.centerYAnchor)
            
        ])
    }
    
    func addTapGesture() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        let tapImageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        avatar.isUserInteractionEnabled = true
        avatar.addGestureRecognizer(tapImageGestureRecognizer)
        name.isUserInteractionEnabled = true
        name.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    @objc private func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.toProfilePage()
        
    }
    
    @objc private func ellipsisToched() {
        
        blockUserDelegate?.didTouchellipsis()
        
    }
}
