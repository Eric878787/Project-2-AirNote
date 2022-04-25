//
//  AddAddressTableViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/18.
//

import UIKit

protocol UploadDelegate {
    func selectButton()
}

class AddAddressTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var uploadButton: UIButton!
    
    var dataHandler: ((String) -> Void)?
    
    var delegate: UploadDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.text = "地點"
        
        uploadButton.setTitle("上傳", for: .normal)
        
        textField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        dataHandler?(textField.text ?? "")
    }
    
    @IBAction func uploadGroup(_ sender: Any) {
        
        delegate?.selectButton()
        
    }
    
    
}
