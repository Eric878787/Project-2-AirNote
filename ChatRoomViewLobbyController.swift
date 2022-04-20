//
//  ChatroomViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/19.
//

import UIKit
import SwiftUI

class ChatRoomViewLobbyController: UIViewController {
    
    // Chat room List TableView
    private var chatRoomListTableView = UITableView(frame: .zero)
    
    // Chat Rooms
    private var chatRoomManager = ChatRoomManager()
    private var chatRooms: [ChatRoom] = []
    private var groupManager = GroupManager()
    private var groups: [Group] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Up Navigation Item
        navigationItem.title = "聊天室"
        
        // Confirure Chat Room List TableView
        configureChatRoomListTableView()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // fetch Data
        checkRoomsChange()
        
    }
    
}

// MARK: Fetch data
extension ChatRoomViewLobbyController {
    private func checkRoomsChange() {
        self.chatRoomManager.checkRoomsChange { [weak self] result in
            
            switch result {
                
            case .success(let rooms):
                
                DispatchQueue.main.async {
                    
                    self?.chatRooms = rooms
                    
                    self?.chatRooms.sort{
                        ( $0.createdTime ) > ( $1.createdTime )
                    }
                    
                    self?.fetchGroups()
                    
                }
                
            case .failure(let error):
                
                print("\(error)")
            }
        }
    }
    
    private func fetchGroups() {
        self.groupManager.fetchGroups { [weak self] result in
            
            switch result {
                
            case .success(let existingGroup):
                
                DispatchQueue.main.async {
                    
                    self?.groups = existingGroup
                    
                    self?.chatRoomListTableView.reloadData()
                    
                }
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
    }
    
}

// MARK: Configure Chat Room List TableView
extension ChatRoomViewLobbyController {
    
    private func configureChatRoomListTableView() {
        
        chatRoomListTableView.registerCellWithNib(identifier: String(describing: ChatRoomListTableViewCell.self), bundle: nil)
        chatRoomListTableView.dataSource = self
        chatRoomListTableView.delegate = self
        
        view.addSubview(chatRoomListTableView)
        
        chatRoomListTableView.translatesAutoresizingMaskIntoConstraints = false
        chatRoomListTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 5).isActive = true
        chatRoomListTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        chatRoomListTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        chatRoomListTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5).isActive = true
        
    }
    
}

// MARK: Chat Room List TableView Delegate
extension ChatRoomViewLobbyController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chatRoomListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ChatRoomListTableViewCell", for: indexPath)
        guard let cell = chatRoomListTableViewCell as? ChatRoomListTableViewCell else { return chatRoomListTableViewCell }
        cell.titleLabel.text = chatRooms[indexPath.row].roomTitle
        
        // querying groups title
        for group in groups where group.groupId == chatRooms[indexPath.row].groupId {
            let url = URL(string: group.groupCover)
            cell.avatarImageView.kf.indicatorType = .activity
            cell.avatarImageView.kf.setImage(with: url)
        }
        return cell
    }
}

// MARK: Chatroom List TableView Datasource
extension ChatRoomViewLobbyController: UITableViewDelegate {
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height * 0.08
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

