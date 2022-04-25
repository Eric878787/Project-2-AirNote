//
//  AddContentViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/12.
//

import UIKit

class AddContentViewController: UIViewController {
    
    private var addNoteButton = UIButton()
    private var addGroupButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Up Navigation Item
        navigationItem.title = "新增內容"
        
        // Init Buttons
        configureAddNoteButton()
        configureAddGroupButton()
        
    }

}

// Configure Buttons
extension AddContentViewController {
    
    private func configureAddNoteButton() {
        
        addNoteButton.translatesAutoresizingMaskIntoConstraints = false
        addNoteButton.setTitle("新增筆記", for: .normal)
        addNoteButton.setTitleColor(.systemGray2, for: .normal)
        addNoteButton.backgroundColor = .systemGray6
        addNoteButton.layer.borderColor = UIColor.clear.cgColor
        addNoteButton.layer.borderWidth = 1
        addNoteButton.layer.cornerRadius = 10
        addNoteButton.addTarget(self, action: #selector(pushToNextPage), for: .touchUpInside)
        view.addSubview(addNoteButton)
        
        addNoteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        addNoteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        addNoteButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -50).isActive = true
        
    }
    
    private func configureAddGroupButton() {
        
        addGroupButton.translatesAutoresizingMaskIntoConstraints = false
        addGroupButton.setTitle("新增讀書會", for: .normal)
        addGroupButton.setTitleColor(.systemGray2, for: .normal)
        addGroupButton.backgroundColor = .systemGray6
        addGroupButton.layer.borderColor = UIColor.clear.cgColor
        addGroupButton.layer.borderWidth = 1
        addGroupButton.layer.cornerRadius = 10
        addGroupButton.addTarget(self, action: #selector(pushToNextPage), for: .touchUpInside)
        view.addSubview(addGroupButton)
        
        addGroupButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        addGroupButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        addGroupButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 50).isActive = true
        
    }
    
}

// MARK: To Next Page
extension  AddContentViewController {
    @objc func pushToNextPage(_ sender: UIButton) {
        if sender == addNoteButton {
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "AddNoteViewController") as? AddNoteViewController else { return }
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "AddGroupViewController") as? AddGroupViewController else { return }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
