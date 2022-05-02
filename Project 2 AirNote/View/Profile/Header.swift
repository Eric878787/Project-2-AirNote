//
//  Header.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/29.
//

import UIKit

class Header: UITableViewHeaderFooterView {
    
    static let reuseIdentifier = String(describing: Header.self)
    
    let segmentController = UISegmentedControl(items: ["Owned", "Saved"])
    
    var segmentHandler: ((Int) -> Void)?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func configure() {
        segmentController.selectedSegmentIndex = 0
        segmentController.selectedSegmentTintColor = .black
        segmentController.tintColor = .white
        segmentController.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentController.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        segmentController.layer.cornerRadius = 10
        segmentController.clipsToBounds = true
        segmentController.addTarget(self, action: #selector(changeNotes), for: .valueChanged)
        addSubview(segmentController)
        segmentController.translatesAutoresizingMaskIntoConstraints = false
        
        let inset: CGFloat = 5
        
        NSLayoutConstraint.activate([
            segmentController.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            segmentController.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            segmentController.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            segmentController.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
        ])
    }
    
    @objc private func changeNotes(sender: UISegmentedControl) {
        
        segmentHandler?(sender.selectedSegmentIndex)
        
    }
    
}
