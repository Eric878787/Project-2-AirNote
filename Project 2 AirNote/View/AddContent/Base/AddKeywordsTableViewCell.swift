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
            
            button.setBackgroundImage(UIImage(systemName: "chevron.down.circle.fill"), for: .normal)
            
            button.tintColor = .myDarkGreen
            
            button.isUserInteractionEnabled = false
            
            categoryTextField.rightView = button
            
            categoryTextField.rightViewMode = .always
            
            categoryTextField.text = "請選擇類別"
            
        }
    }
    @IBOutlet weak var keyWordsTitleLabel: UILabel!
    
    @IBOutlet weak var tagButtonStackView: UIStackView!
    
    private let category: [Category] = [.finance, .workout, .language, .communication, .marketing, .lifestyle, .entertainment]
    
    private var selectedCategory: String?
    
    private var tagCategoryPair: [String: [String]] = ["投資理財": ["基金", "貨幣", "股市", "Stock", "台股"],
                                                       "運動健身": ["有氧", "無氧", "減脂", "增肌", "營養"],
                                                       "語言學習": ["英文", "日文", "韓文", "中文", "法文"],
                                                       "人際溝通": ["職場", "說話", "語言", "交流", "關係"],
                                                       "廣告行銷": ["企劃", "消費者", "洞察", "媒體", "數位"],
                                                       "生活風格": ["日常", "植物", "休閒", "Life", "Style"],
                                                       "藝文娛樂": ["音樂", "繪畫", "舞蹈","展覽","收藏"]]
    private var tags: [String] = []
    
    private var selectedTags: [String] = []
    
    var dataHandler: (([String], String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        categoryTitleLabel.text = "類別"
        categoryTitleLabel.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        keyWordsTitleLabel.text = "關鍵字"
        keyWordsTitleLabel.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        settingDefaultSelection()
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
        
        selectedCategory = category[row].rawValue
        
        guard let unwrappedCategory = selectedCategory else { return }
        
        tags = tagCategoryPair["\(unwrappedCategory)"] ?? []
        
        tagButtonStackView.subviews.forEach({ $0.removeFromSuperview() })
        
        for tag in tags {
            
            let button = UIButton()
            button.setTitle("\(tag)", for: .normal)
            button.setTitleColor( .myDarkGreen , for: .normal)
            button.setTitleColor( .white, for: .selected)
            button.backgroundColor = .white
            button.layer.cornerRadius = 10
            button.layer.borderColor = UIColor.myDarkGreen.cgColor
            button.layer.borderWidth = 1
            button.addTarget(self, action: #selector(didSelectButton), for: .touchUpInside)
            
            tagButtonStackView.addArrangedSubview(button)
            
        }
        
    }
    
    func settingDefaultSelection() {
        
        categoryTextField.text = category[0].rawValue
        
        selectedCategory = category[0].rawValue
        
        guard let unwrappedCategory = selectedCategory else { return }
        
        tags = tagCategoryPair["\(unwrappedCategory)"] ?? []
        
        for tag in tags {
            
            let button = UIButton()
            button.setTitle("\(tag)", for: .normal)
            button.setTitleColor( .myDarkGreen , for: .normal)
            button.setTitleColor( .white, for: .selected)
            button.backgroundColor = .white
            button.layer.cornerRadius = 10
            button.layer.borderColor = UIColor.myDarkGreen.cgColor
            button.layer.borderWidth = 1
            button.addTarget(self, action: #selector(didSelectButton), for: .touchUpInside)
            
            tagButtonStackView.addArrangedSubview(button)
            
        }
        
    }
    
}

extension AddKeywordsTableViewCell {
    
    @objc func didSelectButton(_ sender: UIButton) {
        if sender.isSelected == false {
            sender.isSelected = true
            sender.backgroundColor = .myDarkGreen
            guard let tag = sender.titleLabel?.text else { return }
            selectedTags.append(tag)
        } else {
            sender.isSelected = false
            sender.backgroundColor = .white
            guard let tag = sender.titleLabel?.text else { return }
            selectedTags = selectedTags.filter { $0 != tag }
        }
        guard let selectedCategory = selectedCategory else {return}
        dataHandler?(selectedTags, selectedCategory)
    }
}
