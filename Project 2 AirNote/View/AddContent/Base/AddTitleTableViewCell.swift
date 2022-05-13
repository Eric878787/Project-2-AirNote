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
    @IBOutlet weak var textCountLabel: UILabel!
    
    var dataHandler: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        titleLabel.text = "標題"
        titleLabel.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        titleTextField.delegate = self
        textCountLabel.text = "0/10"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        textCountLabel.text = "\(textField.text?.count ?? 0)/10"
        dataHandler?(text)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 10
    }
    
}
