//
//  Header.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/29.
//

import UIKit

class NoteHeader: UITableViewHeaderFooterView {
    
    static let reuseIdentifier = String(describing: NoteHeader.self)
    
    var firstSegmentController = UISegmentedControl(items: ["Owned", "Saved"])
    
    var firstSegmentHandler: ((Int) -> Void)?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureNoteHeader()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func configureNoteHeader() {
        firstSegmentController.selectedSegmentIndex = 0
        firstSegmentController.selectedSegmentTintColor = .black
        firstSegmentController.tintColor = .white
        firstSegmentController.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        firstSegmentController.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        firstSegmentController.layer.cornerRadius = 10
        firstSegmentController.clipsToBounds = true
        firstSegmentController.addTarget(self, action: #selector(changeNotes), for: .valueChanged)
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
    
    @objc private func changeNotes(sender: UISegmentedControl) {
        
        firstSegmentHandler?(sender.selectedSegmentIndex)
        
    }
    
}
