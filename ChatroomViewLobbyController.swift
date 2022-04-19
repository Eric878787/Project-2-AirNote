//
//  ChatroomViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/19.
//

import UIKit

class ChatroomViewLobbyController: UIViewController {
    
    // Chatroom List TableView
    private var chatroomListTableView = UITableView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Up Navigation Item
        navigationItem.title = "聊天室"
        
        // Confirure Chatroom List TableView
        configureChatroomListTableView()
        
    }
    
}

// MARK: Configure Chatroom List TableView
extension ChatroomViewLobbyController {
    
    private func configureChatroomListTableView() {
        
        chatroomListTableView.registerCellWithNib(identifier: String(describing: ChatroomListTableViewCell.self), bundle: nil)
        chatroomListTableView.dataSource = self
        chatroomListTableView.delegate = self
        
        view.addSubview(chatroomListTableView)
        
        chatroomListTableView.translatesAutoresizingMaskIntoConstraints = false
        chatroomListTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 5).isActive = true
        chatroomListTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        chatroomListTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        chatroomListTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5).isActive = true
        
    }
    
}

// MARK: Chatroom List TableView Delegate
extension ChatroomViewLobbyController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chatroomListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ChatroomListTableViewCell", for: indexPath)
        guard let cell = chatroomListTableViewCell as? ChatroomListTableViewCell else { return chatroomListTableViewCell }
        return cell
    }
}

// MARK: Chatroom List TableView Datasource
extension ChatroomViewLobbyController: UITableViewDelegate {
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height * 0.08
    }
    
}

