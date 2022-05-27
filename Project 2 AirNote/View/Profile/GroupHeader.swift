//
//  GroupHeader.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/5/2.
//

import UIKit

class GroupHeader: UITableViewHeaderFooterView {

    static let reuseIdentifier = String(describing: GroupHeader.self)
    
    var firstSegmentController = UISegmentedControl(items: ["Owned", "Saved"])
    
    var firstSegmentHandler: ((Int) -> Void)?

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
        firstSegmentController.selectedSegmentIndex = 0
        firstSegmentController.selectedSegmentTintColor = .myDarkGreen
        firstSegmentController.backgroundColor = .white
        firstSegmentController.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        firstSegmentController.setTitleTextAttributes([.foregroundColor: UIColor.myDarkGreen], for: .normal)
        firstSegmentController.layer.cornerRadius = 10
        firstSegmentController.clipsToBounds = true
        firstSegmentController.addTarget(self, action: #selector(changeGroups), for: .valueChanged)
        addSubview(firstSegmentController)
        firstSegmentController.translatesAutoresizingMaskIntoConstraints = false
        
        let inset: CGFloat = 5
        
        NSLayoutConstraint.activate([
            firstSegmentController.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            firstSegmentController.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            firstSegmentController.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            firstSegmentController.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
        ])
    }
    
    @objc private func changeGroups(sender: UISegmentedControl) {
        
        firstSegmentHandler?(sender.selectedSegmentIndex)
        
    }

}
