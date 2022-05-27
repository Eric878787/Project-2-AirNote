//
//  SearchContentTableViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/17.
//

import UIKit

protocol NoteResultDelegate {
    
    func saveNote(_ selectedCell: NoteResultTableViewCell)
    
}

class NoteResultTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var mainImageView: UIImageView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var aurthorNameLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
  
    @IBOutlet weak var categoryButton: UIButton!
    
    var delegate: NoteResultDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.borderColor = UIColor.systemGray6.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = .myBeige
        likeButton.tintColor = .myDarkGreen
        configLayout()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.height/2
        avatarImageView.clipsToBounds = true
    }
    
    func configLayout() {
        mainImageView.clipsToBounds = true
        mainImageView.layer.cornerRadius = 10
        categoryButton.layer.borderWidth = 1
        categoryButton.layer.borderColor = UIColor.myBrown.cgColor
        categoryButton.isEnabled = false
        categoryButton.setTitleColor(.myBrown, for: .disabled)
        categoryButton.setTitleColor(.myBrown, for: .normal)
        categoryButton.titleLabel?.font = UIFont(name: "PingFangTC-Semibold", size: 12)
        categoryButton.layer.cornerRadius = 10
        categoryButton.titleEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

    }
    
    
    @IBAction func likeAction(_ sender: Any) {
        
        delegate?.saveNote(self)
        
    }
    
}
