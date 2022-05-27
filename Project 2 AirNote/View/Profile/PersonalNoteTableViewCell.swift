//
//  SavedNoteTableViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/24.
//

import UIKit
import Kingfisher

class PersonalNoteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mainImageView: UIImageView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var categoryButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.borderColor = UIColor.systemGray6.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = .myBeige
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
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
    
    func layoutCell(_ notes: [Note], _ users: [User], _ indexPath: IndexPath) {
        
        let url = URL(string: notes[indexPath.row].cover)
        mainImageView.kf.indicatorType = .activity
        mainImageView.kf.setImage(with: url)
        
        // querying users' name & avatar
        for user in users where user.uid == notes[indexPath.row].authorId {
            nameLabel.text = user.userName
            let url = URL(string: user.userAvatar)
            avatarImageView.kf.indicatorType = .activity
            avatarImageView.kf.setImage(with: url)
        }
        
        titleLabel.text = notes[indexPath.row].title
        categoryButton.setTitle("\(notes[indexPath.row].category)", for: .normal)
    }
    
}
