//
//  AddNoteTableViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/12.
//

import UIKit

class AddTitleTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    
    var dataHandler: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        titleLabel.text = "標題"
        titleTextField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        dataHandler?(text)
    }
    
}
