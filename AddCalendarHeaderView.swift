//
//  AddCalendarHeaderView.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/5/11.
//

import UIKit

protocol AddCalendarHeaderViewDelegate {
    
    func addCalendar(_ header: AddCalendarHeaderView)
    
    func minusCalendar(_ header: AddCalendarHeaderView)
    
}

class AddCalendarHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var minusButton: UIButton!
    
    var delegate: AddCalendarHeaderViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.text = "行事曆"
        
        titleLabel.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        
        addButton.setTitleColor( .myDarkGreen, for: .normal)
        
        addButton.setTitleColor( .systemGray6, for: .disabled)
        
        addButton.tintColor = .myDarkGreen
        
        minusButton.setTitleColor( .myDarkGreen, for: .normal)
        
        minusButton.setTitleColor( .systemGray6, for: .disabled)
        
        minusButton.tintColor = .myDarkGreen
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    @IBAction func addCalendar(_ sender: Any) {
        
        delegate?.addCalendar(self)
        
        
    }
    
    @IBAction func minusCalendar(_ sender: Any) {
        
        delegate?.minusCalendar(self)
        
    }
    
}
