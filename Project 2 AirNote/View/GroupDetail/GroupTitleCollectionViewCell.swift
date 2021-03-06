//
//  GroupTitleCollectionViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/23.
//

import UIKit

protocol GroupTitleDelegate {
    
    func joinOrQuit(_ selectedCell: GroupTitleCollectionViewCell)
    
}

class GroupTitleCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifer = "GroupTitleCollectionViewCell"
    
    @IBOutlet weak var locationIcon: UIImageView!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var dateIcon: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var memberIcon: UIImageView!
    
    @IBOutlet weak var memberLabel: UILabel!
    
    @IBOutlet weak var applyButton: UIButton!
    
    var delegate: GroupTitleDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        locationIcon.tintColor = .myDarkGreen
        dateIcon.tintColor = .myDarkGreen
        memberIcon.tintColor = .myDarkGreen
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        locationIcon.image = UIImage(systemName: "mappin.and.ellipse")
        dateIcon.image = UIImage(systemName: "calendar")
        memberIcon.image = UIImage(systemName: "person.3.fill")
        applyButton.layer.cornerRadius = 10
        applyButton.clipsToBounds = true
    }
    
    @IBAction func joinGroup(_ sender: Any) {
        
        delegate?.joinOrQuit(self)
        
    }
}
