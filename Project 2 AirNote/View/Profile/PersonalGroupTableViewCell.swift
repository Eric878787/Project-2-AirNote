//
//  PersonalGroupTableViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/30.
//

import UIKit
import Kingfisher

class PersonalGroupTableViewCell: UITableViewCell {
    
    @IBOutlet weak var coverImage: UIImageView!
    
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var dateIcon: UIImageView!
    
    @IBOutlet weak var membersIcon: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var memberCountsLabel: UILabel!
    
    @IBOutlet weak var categoryButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.borderColor = UIColor.systemGray6.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = .myBeige
        dateIcon.tintColor = .myDarkGreen
        membersIcon.tintColor = .myDarkGreen
        configLayout()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        avatarImage.layer.cornerRadius = avatarImage.bounds.height/2
        avatarImage.clipsToBounds = true
    }
    
    func configLayout() {
        coverImage.clipsToBounds = true
        coverImage.layer.cornerRadius = 10
        categoryButton.layer.borderWidth = 1
        categoryButton.layer.borderColor = UIColor.myBrown.cgColor
        categoryButton.isEnabled = false
        categoryButton.setTitleColor(.myBrown, for: .disabled)
        categoryButton.setTitleColor(.myBrown, for: .normal)
        categoryButton.titleLabel?.font = UIFont(name: "PingFangTC-Semibold", size: 12)
        categoryButton.layer.cornerRadius = 10
        categoryButton.titleEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

    }
    
    func layoutCell(_ groups: [Group], _ users: [User], _ indexPath: IndexPath) {
        
        let url = URL(string: groups[indexPath.row].groupCover)
        coverImage.kf.indicatorType = .activity
        coverImage.kf.setImage(with: url)
        
        // querying users' name & avatar
        for user in users where user.uid == groups[indexPath.row].groupOwner {
            nameLabel.text = user.userName
            let url = URL(string: user.userAvatar)
            avatarImage.kf.indicatorType = .activity
            avatarImage.kf.setImage(with: url)
        }
        let date = groups[indexPath.row].createdTime
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        dateLabel.text = formatter.string(from: date)
        titleLabel.text = groups[indexPath.row].groupTitle
        categoryButton.setTitle("\(groups[indexPath.row].groupCategory)", for: .normal)
        memberCountsLabel.text = "\(groups[indexPath.row].groupMembers.count)"
    }
    
}
