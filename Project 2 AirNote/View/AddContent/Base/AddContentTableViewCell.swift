//
//  AddContentTableViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/13.
//

import UIKit

class AddContentTableViewCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var textCountLabel: UILabel!
    
    var dataHandler: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        titleLabel.text = "內容"
        titleLabel.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        contentTextView.delegate = self
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.systemGray6.cgColor
        contentTextView.layer.cornerRadius = 10
        textCountLabel.text = "0/100"
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let text = textView.text else { return }
        textCountLabel.text = "\(contentTextView.text?.count ?? 0)/100"
        dataHandler?(text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 100
    }
}
