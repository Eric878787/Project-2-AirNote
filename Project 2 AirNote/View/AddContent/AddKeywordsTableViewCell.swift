//
//  AddKeywordsTableViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/13.
//

import UIKit

private enum Category: String {
    
    case finance = "投資理財"
    
    case workout = "運動健身"
    
    case language = "語言學習"
    
    case communication = "人際溝通"
    
    case marketing = "廣告行銷"
    
    case lifestyle = "生活風格"
    
    case entertainment = "藝文娛樂"
    
}

class AddKeywordsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var categoryTextField: UITextField! {
        
        didSet {
            
            let categoryPicker = UIPickerView()
            
            categoryPicker.dataSource = self
            
            categoryPicker.delegate = self
            
            categoryTextField.inputView = categoryPicker
            
            let button = UIButton(type: .custom)
            
            button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            
            button.setBackgroundImage(UIImage(systemName: "arrow.down"), for: .normal)
            
            button.isUserInteractionEnabled = false
            
            categoryTextField.rightView = button
            
            categoryTextField.rightViewMode = .always
            
            categoryTextField.delegate = self
            
            categoryTextField.text = "請選擇類別"
            
        }
    }
    @IBOutlet weak var keyWordsTitleLabel: UILabel!
    
    @IBOutlet weak var tagButtonStackView: UIStackView!
    
    private let category: [Category] = [.finance, .workout, .language, .communication, .marketing, .lifestyle, .entertainment]
    
    private var selectedCategory: String?
    
    private var tagCategoryPair: [String: [String]] = ["投資理財": ["投資", "理財", "股市", "stock", "台股"],
                                                       "運動健身": ["有氧", "無氧", "減脂", "增肌", "運動"],
                                                       "語言學習": ["英文", "日文", "韓文", "中文", "法文"],
                                                       "人際溝通": ["1", "2", "3", "4", "5"],
                                                       "廣告行銷": ["a", "b", "c", "d", "e"],
                                                       "生活風格": ["1", "2"],
                                                       "藝文娛樂": ["a", "b"]]
    private var tags: [String] = []
    
    private var selectedTags: [String] = []
    
    var dataHandler: (([String], String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        categoryTitleLabel.text = "類別"
        keyWordsTitleLabel.text = "關鍵字"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension AddKeywordsTableViewCell: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        7
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        category[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryTextField.text = category[row].rawValue
    }
    
}

extension AddKeywordsTableViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let category = textField.text else { return }
        
        selectedCategory = category
        
        guard let unwrappedCategory = selectedCategory else { return }
        
        tags = tagCategoryPair["\(unwrappedCategory)"] ?? []
        
        tagButtonStackView.subviews.forEach({ $0.removeFromSuperview() })
        
        for tag in tags {
            
            let button = UIButton()
            button.setTitle("\(tag)", for: .normal)
            button.setTitleColor( .black, for: .selected)
            button.backgroundColor = .systemGray2
            button.addTarget(self, action: #selector(didSelectButton), for: .touchUpInside)
            
            tagButtonStackView.addArrangedSubview(button)
            
        }
        
    }
    
    @objc func didSelectButton(_ sender: UIButton) {
        sender.isSelected = true
        guard let tag = sender.titleLabel?.text else { return }
        selectedTags.append(tag)
        guard let selectedCategory = selectedCategory else {return}
        dataHandler?(selectedTags, selectedCategory)
        
    }
}
