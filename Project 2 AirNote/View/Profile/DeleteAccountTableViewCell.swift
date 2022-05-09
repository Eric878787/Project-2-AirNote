//
//  DeleteAccountTableViewCell.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/5/8.
//

import UIKit

protocol DeleteAccountDelegate {
    
    func tapDeleteAccountButton()
}

class DeleteAccountTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing:  DeleteAccountTableViewCell.self)
    
    var delegate: DeleteAccountDelegate?
    
    let deleteButton = UIButton()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configure()
    }
    
    func configure() {
        deleteButton.setTitle("刪除帳號", for: .normal)
        deleteButton.setTitleColor(.red, for: .normal)
        deleteButton.layer.borderWidth = 1
        deleteButton.layer.borderColor = UIColor.red.cgColor
        deleteButton.titleLabel?.font = UIFont(name: "PingFangTC-Semibold", size: 14)
        deleteButton.layer.cornerRadius = 10
        deleteButton.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(deleteButton)
        
        let inset: CGFloat = 100
        
        NSLayoutConstraint.activate([
            deleteButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            deleteButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            deleteButton.centerXAnchor.constraint(equalTo: centerXAnchor)
         
        ])
    }
    
    @objc func tapButton() {
        
        delegate?.tapDeleteAccountButton()
        
    }
    
    

}
