//
//  Header.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/29.
//

import UIKit

class NoteHeader: UITableViewHeaderFooterView {
    
    static let reuseIdentifier = String(describing: NoteHeader.self)
    
    var title = UILabel()
    
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
