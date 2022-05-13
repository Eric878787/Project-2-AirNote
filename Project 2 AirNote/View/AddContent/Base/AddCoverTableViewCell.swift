//
//  addCoverTableViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/14.
//
import UIKit

protocol CoverDelegate {
    func buttonDidSelect ()
}

class AddCoverTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var selectButton: UIButton!
    
    var delegate: CoverDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = "封面"
        titleLabel.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        self.selectionStyle = .none
        coverImageView.tintColor = .myDarkGreen
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectButton.setTitle("新增封面", for: .normal)
        selectButton.setTitleColor( .white, for: .normal)
        selectButton.backgroundColor = .myDarkGreen
        selectButton.layer.cornerRadius = 10
        selectButton.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func addCover(_ sender: Any) {
        delegate?.buttonDidSelect()
    }

}
