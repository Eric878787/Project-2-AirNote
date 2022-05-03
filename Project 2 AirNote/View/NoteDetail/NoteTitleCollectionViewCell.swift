//
//  NoteTitleCollectionViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/22.
//

import UIKit

protocol NoteTitleDelegate {
    
    func saveNote(_ selectedCell: NoteTitleCollectionViewCell)
    
}

class NoteTitleCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifer = "NoteTitleCollectionViewCell"
    
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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = .systemGray2
        viewsIcon.image = UIImage(systemName: "eye")
        commentCountsIcon.image = UIImage(systemName: "message")
    }
    
    @IBAction func didTouchSaveBitton(_ sender: Any) {
        
        delegate?.saveNote(self)
        
    }
    
}
