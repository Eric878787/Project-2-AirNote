//
//  ChatRoomViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/20.
//

import UIKit
import Kingfisher

class ChatRoomViewController: UIViewController {
    
    // Chat Room TableView
    private var chatRoomTableView = UITableView(frame: .zero)
    
    // Message TextView
    private var messageTextView = UITextView(frame: .zero)
    
    // Send Button
    private var sendButton = UIButton(frame: .zero)
    
    // Pick Image Button
    private var imageButton = UIButton(frame: .zero)
    
    // Image Picker
    private let imagePickerController = UIImagePickerController()
    
    // Chat Room DataSource
    var group: Group?
    
    private var chatRoomManager = ChatRoomManager()
    
    // Selected Image
    private var selectedImage = UIImage()
    
    // Image To Show
    private var imageToShow = UIImageView()
    
    // Users DataSource
    private var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Up Navigation Item
        
        // Configure Layouts
        configureChatRoomTableView()
        configureImageButton()
        configureTextView()
        configureSendButton()
        
        // Datasource
        checkMessagesChange()
        
        // Image Picker
        imagePickerController.delegate = self
        
    }
    
}
// MARK: Fetch data
extension ChatRoomViewController {
    
    private func checkMessagesChange() {
        GroupManager.shared.checkMessageChange(groupId: self.group?.groupId ?? "") { [weak self] result in
            switch result {
                
            case .success(let group):
                
                DispatchQueue.main.async {
                    
                    self?.group = group
                    self?.group?.messages.sort{
                        ( $0.createdTime ) < ( $1.createdTime )
                    }
                    
                    self?.fetchUsers()
                    
                }
                
            case .failure(let error):
                
                print("\(error)")
            }
        }
    }
    
    private func fetchUsers() {
        UserManager.shared.fetchUsers { [weak self] result in
            
            switch result {
                
            case .success(let existingUser):
                
                DispatchQueue.main.async {
                    self?.users = existingUser
                    self?.chatRoomTableView.reloadData()
                    if self?.group?.messages != [] {
                        self?.chatRoomTableView.scrollToRow(at: [0, (self?.group?.messages.count ?? 1) - 1] , at: .bottom, animated: false)
                    }
                }
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
    }
}


// MARK: Configure Layouts
extension ChatRoomViewController {
    
    private func configureChatRoomTableView() {
        
        chatRoomTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        chatRoomTableView.registerCellWithNib(identifier: String(describing: LeftChatRoomTableViewCell.self), bundle: nil)
        chatRoomTableView.registerCellWithNib(identifier: String(describing: RightChatRoomTableViewCell.self), bundle: nil)
        chatRoomTableView.dataSource = self
        
        view.addSubview(chatRoomTableView)
        
        chatRoomTableView.translatesAutoresizingMaskIntoConstraints = false
        chatRoomTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 5).isActive = true
        chatRoomTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        chatRoomTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5).isActive = true
        
    }
    
    private func configureImageButton() {
        
        imageButton.layer.borderWidth = 1
        imageButton.layer.borderColor = UIColor.systemGray6.cgColor
        imageButton.layer.cornerRadius = 10
        imageButton.setImage(UIImage(systemName: "photo.fill"), for: .normal)
        imageButton.tintColor = .myDarkGreen
        imageButton.addTarget(self, action: #selector(sendImageMessage), for: .touchUpInside)
        view.addSubview(imageButton)
        
        imageButton.translatesAutoresizingMaskIntoConstraints = false
        imageButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        imageButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        imageButton.widthAnchor.constraint(equalTo: imageButton.heightAnchor).isActive = true
        imageButton.topAnchor.constraint(equalTo: chatRoomTableView.bottomAnchor, constant: 10).isActive = true
        imageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        
    }
    
    private func configureTextView() {
        
        messageTextView.layer.borderWidth = 1
        messageTextView.layer.borderColor = UIColor.systemGray6.cgColor
        messageTextView.layer.cornerRadius = 10
        view.addSubview(messageTextView)
        
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.leadingAnchor.constraint(equalTo: imageButton.trailingAnchor, constant: 10).isActive = true
        messageTextView.topAnchor.constraint(equalTo: imageButton.topAnchor).isActive = true
        messageTextView.bottomAnchor.constraint(equalTo: imageButton.bottomAnchor).isActive = true
        
    }
    
    private func configureSendButton() {
        
        sendButton.layer.borderWidth = 1
        sendButton.layer.borderColor = UIColor.systemGray6.cgColor
        sendButton.layer.cornerRadius = 10
        sendButton.setImage(UIImage(systemName: "arrowtriangle.right.fill"), for: .normal)
        sendButton.tintColor = .myDarkGreen
        sendButton.addTarget(self, action: #selector(sendTextMessage), for: .touchUpInside)
        view.addSubview(sendButton)
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.leadingAnchor.constraint(equalTo: messageTextView.trailingAnchor, constant: 10).isActive = true
        sendButton.topAnchor.constraint(equalTo: messageTextView.topAnchor).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: messageTextView.bottomAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalTo: sendButton.heightAnchor).isActive = true
        sendButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        
    }
    
}

// MARK: Send Message
extension ChatRoomViewController {
    
    @objc private func sendTextMessage() {
        guard let uid = FirebaseManager.shared.currentUser?.uid else { return }
        let message = Message(sender: uid, createdTime: Date(), content: messageTextView.text)
        self.group?.messages.append(message)
        guard let group = self.group else { return }
        GroupManager.shared.updateGroup(group: group, groupId: group.groupId) { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.messageTextView.text = ""
                    self?.chatRoomTableView.reloadData()
                }
            case .failure(let error):
                print("fetchData.failure: \(error)")
            }
        }
    }
    
    @objc private func sendImageMessage() {
        imagePickerController.sourceType = .savedPhotosAlbum
        self.present(imagePickerController, animated: true)
    }
    
}

// MARK: Image Picker
extension ChatRoomViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            selectedImage = image
            GroupManager.shared.uploadPhoto(image: selectedImage) { [weak self] result in
                switch result {
                case .success(let url):
                    guard let uid = FirebaseManager.shared.currentUser?.uid else { return }
                    let message = Message(sender: uid, createdTime: Date(), image: "\(url)")
                    self?.group?.messages.append(message)
                    guard let group = self?.group else { return }
                    GroupManager.shared.updateGroup(group: group, groupId: group.groupId) { [weak self] result in
                        switch result {
                        case .success:
                            DispatchQueue.main.async {
                                self?.chatRoomTableView.reloadData()
                            }
                        case .failure(let error):
                            print("fetchData.failure: \(error)")
                        }
                    }
                case .failure(let error):
                    print("\(error)")
                }
            }
            
        }
        picker.dismiss(animated: true)
    }
}

// MARK: Chat Room TableView Delegate
extension ChatRoomViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        group?.messages.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let uid = FirebaseManager.shared.currentUser?.uid else { return UITableViewCell() }
        guard let group = self.group else { return UITableViewCell() }
        if group.messages[indexPath.row].sender == uid {
            let rightChatRoomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RightChatRoomTableViewCell", for: indexPath)
            guard let cell = rightChatRoomTableViewCell as? RightChatRoomTableViewCell else { return rightChatRoomTableViewCell }
            let url = URL(string:group.messages[indexPath.row].image ?? "")
            cell.messageImage.kf.indicatorType = .activity
            cell.messageImage.kf.setImage(with: url)
            cell.messageLabel.text = group.messages[indexPath.row].content
            
            if group.messages[indexPath.row].image == nil {
                cell.messageImage.isHidden = true
            } else { cell.messageImage.isHidden = false }
            
            return cell
        } else {
            let leftChatRoomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LeftChatRoomTableViewCell", for: indexPath)
            guard let cell = leftChatRoomTableViewCell as? LeftChatRoomTableViewCell else { return leftChatRoomTableViewCell }
            let url = URL(string:group.messages[indexPath.row].image ?? "")
            cell.messageImage.kf.indicatorType = .activity
            cell.messageImage.kf.setImage(with: url)
            cell.messageLabel.text = group.messages[indexPath.row].content
            
            if group.messages[indexPath.row].image == nil {
                cell.messageImage.isHidden = true
            } else { cell.messageImage.isHidden = false }
            
            // querying users' name & avatar
            for user in users where user.uid == group.messages[indexPath.row].sender {
                cell.nameLabel.text = user.userName
                let url = URL(string: user.userAvatar)
                cell.avatarImageView.kf.indicatorType = .activity
                cell.avatarImageView.kf.setImage(with: url)
            }
            
            return cell
        }
    }
}
