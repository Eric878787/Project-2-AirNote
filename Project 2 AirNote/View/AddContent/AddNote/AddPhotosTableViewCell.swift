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
    
    var delegate: SelectImagesDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    @IBOutlet var bookImageViews: [UIImageView]!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func uploadNote(_ sender: Any) {
        delegate?.uploadNote()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func selectImages(_ sender: Any) {
        delegate?.selectMultiImages()
        titleLabel.text = "內頁"
        addButton.setTitle("上傳", for: .normal)
    }
}
