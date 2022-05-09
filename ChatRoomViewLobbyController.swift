//
//  ChatroomViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/19.
//

import UIKit

class ChatRoomViewLobbyController: UIViewController {
    
    // Chat room List TableView
    private var chatRoomListTableView = UITableView(frame: .zero)
    
    // Chat Rooms
    private var groups: [Group] = []
    
    // User
    private var user: User?
    
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
        fetchuser()
        
    }
    
}

// MARK: Fetch data
extension ChatRoomViewLobbyController {
    
    private func fetchuser() {
        
        guard let uid = FirebaseManager.shared.currentUser?.uid else { return }
        UserManager.shared.fetchUser(uid) { result in
            switch result {
            case .success(let user):
                self.user = user
                self.fetchGroups()
                
            case .failure(let error):
                print (error)
            }
        }
    }
    
    private func fetchGroups() {
        
        guard let groupIds = self.user?.joinedGroups else { return }
        
        GroupManager.shared.fetchSpecificGroups(groupIds: groupIds){ [weak self] result in
            
            switch result {
                
            case .success(let groups):
                
                self?.groups = groups
                
                self?.groups.sort{
                    ( $0.createdTime ) > ( $1.createdTime )
                }
                
                self?.chatRoomListTableView.reloadData()
                
            case .failure(let error):
                
                print("\(error)")
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
        chatRoomListTableView.separatorStyle = .none
        
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
        groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chatRoomListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ChatRoomListTableViewCell", for: indexPath)
        guard let cell = chatRoomListTableViewCell as? ChatRoomListTableViewCell else { return chatRoomListTableViewCell }
        cell.titleLabel.text = groups[indexPath.row].groupTitle
        
        let url = URL(string: groups[indexPath.row].groupCover)
        cell.avatarImageView.kf.indicatorType = .activity
        cell.avatarImageView.kf.setImage(with: url)
        return cell
    }
}

// MARK: Chatroom List TableView Datasource
extension ChatRoomViewLobbyController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height * 0.08
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "ChatroomLobby", bundle: nil)
        guard let vc =  storyBoard.instantiateViewController(withIdentifier: "ChatRoomViewController") as? ChatRoomViewController else { return }
        vc.group = groups[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

