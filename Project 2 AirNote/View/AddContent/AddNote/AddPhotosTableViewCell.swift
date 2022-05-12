//
//  AddPhotosTableViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/14.
//

import UIKit

protocol SelectImagesDelegate {
    func selectMultiImages()
    func uploadNote()
}

class AddPhotosTableViewCell: UITableViewCell {
    
    @IBOutlet var bookImageViews: [UIImageView]!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var uploadButton: UIButton!
    
    var delegate: SelectImagesDelegate?

    override func awakeFromNib() {
        self.selectionStyle = .none
        super.awakeFromNib()
        titleLabel.text = "內頁"
        titleLabel.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        for imageView in bookImageViews {
            imageView.tintColor = .myDarkGreen
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addButton.setTitle("新增圖片", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = .myDarkGreen
        addButton.layer.cornerRadius = 10
        addButton.clipsToBounds = true
        
        uploadButton.setTitle("上傳", for: .normal)
        uploadButton.setTitleColor(.myDarkGreen, for: .normal)
        uploadButton.backgroundColor = .white
        uploadButton.layer.borderColor = UIColor.myDarkGreen.cgColor
        uploadButton.layer.borderWidth = 1
        uploadButton.layer.cornerRadius = 10
        uploadButton.clipsToBounds = true
        uploadButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func uploadNote(_ sender: Any) {
        delegate?.uploadNote()
    }
    
    @IBAction func selectImages(_ sender: Any) {
        delegate?.selectMultiImages()
    }
    
}
