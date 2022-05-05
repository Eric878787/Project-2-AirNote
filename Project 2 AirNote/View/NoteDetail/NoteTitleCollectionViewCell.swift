//
//  NoteTitleCollectionViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/22.
//

import UIKit

protocol NoteTitleDelegate {
    
    func saveNote(_ selectedCell: NoteTitleCollectionViewCell)
    func toProfilePage()
    
}

class NoteTitleCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifer = "NoteTitleCollectionViewCell"
    
    @IBOutlet weak var userAvatar: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var viewsIcon: UIImageView!
    
    @IBOutlet weak var viewsLabel: UILabel!
    
    @IBOutlet weak var commentCountsIcon: UIImageView!
    
    @IBOutlet weak var commentCountsLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var delegate: NoteTitleDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewsIcon.tintColor = .myDarkGreen
        commentCountsIcon.tintColor = .myDarkGreen
        saveButton.tintColor = .myDarkGreen
        
        // Tap Avatar
        addTapGesture()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = .systemGray2
        userAvatar.layer.cornerRadius = userAvatar.frame.height / 2
        userAvatar.clipsToBounds = true
        viewsIcon.image = UIImage(systemName: "eye")
        commentCountsIcon.image = UIImage(systemName: "message")
    }
    
    @IBAction func didTouchSaveBitton(_ sender: Any) {
        
        delegate?.saveNote(self)
        
    }
    
    private func addTapGesture() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        userAvatar.isUserInteractionEnabled = true
        userAvatar.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    @objc private func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        
        delegate?.toProfilePage()
        
    }
    
}
