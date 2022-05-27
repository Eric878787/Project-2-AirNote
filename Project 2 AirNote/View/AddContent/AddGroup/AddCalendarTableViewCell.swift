//
//  AddCalendarTableViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/18.
//

import UIKit

class AddCalendarTableViewCell: UITableViewCell {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var textField: UITextField!
    
    var textHandler: ((String) -> Void)?
    
    var dateHandler: ((Date) -> Void)?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        datePicker.contentHorizontalAlignment = .leading
        
        textField.delegate = self
        
        
        
    }
    
    @IBAction func changeDate(_ sender: UIDatePicker) {
        
        dateHandler?(sender.date)
    
    }
    
}

extension AddCalendarTableViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {

        textHandler?(textField.text ?? "")

    }
    
}
