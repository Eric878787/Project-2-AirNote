//
//  GroupHeader.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/5/2.
//

import UIKit

class GroupHeader: UITableViewHeaderFooterView {

    static let reuseIdentifier = String(describing: GroupHeader.self)
    
    var title = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureGroupHeader()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func configureGroupHeader() {
        title.textColor = .black
        title.font = UIFont(name: "PingFangTC-Semibold", size: 16)
        title.translatesAutoresizingMaskIntoConstraints = false
        addSubview(title)
        
        let inset: CGFloat = 5
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            title.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            title.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
        ])
    }

}
