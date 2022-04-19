//
//  AddCalendarTableViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/18.
//

import UIKit

class AddCalendarTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var datePickerView: UIView!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    private var date = Date()

    private var dateArray: [Date] = []
    
    private var textArray: [String] = []
    
    private var textFields: [UITextField] = []
    
    private var tagCount = 0
    
    var calendarHandler: (([Date], [String]) -> Void)?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        titleLabel.text = "行事曆"
        
        confirmButton.setTitle("確認", for: .normal)
        
        confirmButton.setTitleColor( .red, for: .normal)
        
        confirmButton.layer.cornerRadius = 10
        
        confirmButton.layer.borderWidth = 1
        
        confirmButton.layer.borderColor = UIColor.clear.cgColor
        
        confirmButton.backgroundColor = .white
        
        datePickerView.backgroundColor = .systemGray6
        
        datePickerView.layer.cornerRadius = 10
        
        datePickerView.isHidden = true
    }
    
    @IBAction func addCalendar(_ sender: Any) {
        
        datePickerView.isHidden = true
        
        dateArray.append(date)
        
        textArray.append("")
        
        layoutCalendars()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func layoutCalendars() {
        
        stackView.subviews.forEach({ $0.removeFromSuperview() })
        
        textFields = []
        
        tagCount = 0
        
        for date in dateArray {
            
            layoutCalendar()
            
        }
        
    }
    
    func layoutCalendar() {
        
        let calendarButton = UIButton()
        
        calendarButton.tag = tagCount
        
        let agendaTextfield = UITextField()
        
        agendaTextfield.tag = tagCount
        
        textFields.append(agendaTextfield)
        
        agendaTextfield.text = textArray[agendaTextfield.tag]
        
        agendaTextfield.delegate = self
        
        let innerStackView = UIStackView()
        
        innerStackView.axis = .horizontal
        
        innerStackView.distribution = .fillProportionally
        
        innerStackView.spacing = 5
        
        stackView.addArrangedSubview(innerStackView)
        
        innerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        calendarButton.addTarget(self, action: #selector(changeDate), for: .touchUpInside)
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MM/dd"
        
        calendarButton.setTitle("\(dateFormatter.string(from: dateArray[calendarButton.tag]))", for: .normal)
        
        calendarButton.setTitleColor(.black, for: .normal)
        
        calendarButton.titleLabel?.font = UIFont(name: "Arial", size: 12)
        
        calendarButton.backgroundColor = .systemGray6
        
        calendarButton.layer.borderWidth = 1
        
        calendarButton.layer.borderColor = UIColor.clear.cgColor
        
        calendarButton.layer.cornerRadius = 10
        
        innerStackView.addArrangedSubview(calendarButton)
        
        calendarButton.translatesAutoresizingMaskIntoConstraints = false
        
        calendarButton.widthAnchor.constraint(equalTo: innerStackView.widthAnchor, multiplier: 0.1).isActive = true
        
        calendarButton.heightAnchor.constraint(equalTo: calendarButton.widthAnchor).isActive = true
        
        agendaTextfield.layer.borderWidth = 1
        
        agendaTextfield.layer.borderColor = UIColor.clear.cgColor
        
        agendaTextfield.borderStyle = .roundedRect
        
        innerStackView.addArrangedSubview(agendaTextfield)
        
        tagCount += 1
        
    }
    
    @objc func changeDate(_ sender: UIButton) {
        
        confirmButton.tag = sender.tag
        
        datePickerView.isHidden = false
    }
    
    @IBAction func confirmDate(_ sender: UIButton) {
        
        dateArray[sender.tag] = datePicker.date
        
        layoutCalendars()
        
        datePickerView.isHidden = true
        
    }
    
}

extension AddCalendarTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        textArray[textField.tag] = textFields[textField.tag].text ?? ""
        
        calendarHandler?(dateArray, textArray)

    }
}
