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
    
    var indexOfMessageToBeDeleted: Int?
    
    private var chatRoomManager = ChatRoomManager()
    
    // Selected Image
    private var selectedImage = UIImage()
    
    // Image To Show
    private var imageToShow = UIImageView()
    
    // Users DataSource
    private var users: [User] = []
    private var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide Tab Bar
        self.tabBarController?.tabBar.isHidden = true
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
}
// MARK: Fetch data
extension ChatRoomViewController {
    
    private func checkMessagesChange() {
        GroupManager.shared.checkMessageChange(groupId: self.group?.groupId ?? "") { [weak self] result in
            switch result {
                
            case .success(let group):
                    
                    self?.group = group
                    self?.group?.messages.sort{
                        ( $0.createdTime ) < ( $1.createdTime )
                    }
                    
                    self?.fetchUsers()
                
            case .failure(let error):
                
                print("\(error)")
            }
        }
    }
    
    private func fetchUsers() {
        UserManager.shared.fetchUsers { [weak self] result in
            
            switch result {
                
            case .success(let existingUser):
                
                self?.users = existingUser
                
                for user in existingUser where user.uid == FirebaseManager.shared.currentUser?.uid {
                    self?.user = user
                }
                
                // Filter Blocked Users
                guard let blockedUids = self?.user?.blockUsers else { return }
                
                for blockedUid in blockedUids {
                    
                    self?.users = self?.users.filter{ $0.uid != blockedUid} ?? []
                    
                }
                
                // Filter Blocked Users Content
                
                guard let messages = self?.group?.messages else { return }
                
                for blockedUid in blockedUids {
                    
                    self?.group?.messages = messages.filter{ $0.sender != blockedUid} ?? []
                    
                }
                
                DispatchQueue.main.async {
                    self?.chatRoomTableView.reloadData()
                    if self?.group?.messages != [] {
                        self?.chatRoomTableView.scrollToRow(at: [0, (self?.group?.messages.count ?? 1) - 1], at: .bottom, animated: false)
                    }
                }
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
    }
}

// MARK: Delete Message
extension ChatRoomViewController {
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            let touchPoint = sender.location(in: chatRoomTableView)
            if let indexPath = chatRoomTableView.indexPathForRow(at: touchPoint) {
                indexOfMessageToBeDeleted = indexPath.row
                
                if group?.messages[indexPath.row].sender == FirebaseManager.shared.currentUser?.uid {
                
                openActionList()
                    
                } else {
                    
                    return
                    
                }
            }
        }
    }
    
    @objc private func openActionList() {
        
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "刪除訊息", style: .default) { action in
            LKProgressHUD.show()
            self.deleteMessage()
        }
        controller.addAction(action)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        
        // iPad Situation
        if let popoverController = controller.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        self.present(controller, animated: true)
        
    }
    
    private func deleteMessage() {
        guard let indexPathForRow = indexOfMessageToBeDeleted else { return }
        self.group?.messages.remove(at: indexPathForRow)
        guard let group = self.group else { return }
        GroupManager.shared.updateGroup(group: group, groupId: group.groupId) { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    LKProgressHUD.dismiss()
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
        chatRoomTableView.registerCellWithNib(identifier: String(describing: LeftImageTableViewCell.self), bundle: nil)
        chatRoomTableView.registerCellWithNib(identifier: String(describing: RightImageTableViewCell.self), bundle: nil)
        chatRoomTableView.dataSource = self
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        chatRoomTableView.addGestureRecognizer(longPress)
        
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
        messageTextView.font = UIFont(name: "PingFangTC-Regular", size: 14)
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
                            print("\(result)")
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
            
            if group.messages[indexPath.row].image == nil {
                
                let rightChatRoomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RightChatRoomTableViewCell", for: indexPath)
                guard let cell = rightChatRoomTableViewCell as? RightChatRoomTableViewCell else { return rightChatRoomTableViewCell }
                cell.messageLabel.text = group.messages[indexPath.row].content
                let localDate = group.messages[indexPath.row].createdTime
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d, h:mm a"
                cell.createdTimeLabel.text =  dateFormatter.string(from: localDate)
                
                return cell
              
            } else {
                
                let rightImageTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RightImageTableViewCell", for: indexPath)
                guard let cell = rightImageTableViewCell as? RightImageTableViewCell else { return rightImageTableViewCell }
                let url = URL(string:group.messages[indexPath.row].image ?? "")
                cell.messageImage.kf.indicatorType = .activity
                cell.messageImage.kf.setImage(with: url)
                let localDate = group.messages[indexPath.row].createdTime
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d, h:mm a"
                cell.createdTimeLabel.text =  dateFormatter.string(from: localDate)
                
                cell.imageHandler = {
                    
                    let vc = ImageViewerViewController()
                    guard let image = group.messages[indexPath.row].image else { return }
                    vc.images.append(image)
                    vc.currentPage = 0
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }
                
                return cell
            
            }
            
        } else {
            
            if group.messages[indexPath.row].image == nil {
                
                let leftChatRoomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LeftChatRoomTableViewCell", for: indexPath)
                guard let cell = leftChatRoomTableViewCell as? LeftChatRoomTableViewCell else { return leftChatRoomTableViewCell }
                var sender: User?
                cell.messageLabel.text = group.messages[indexPath.row].content
                let localDate = group.messages[indexPath.row].createdTime
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d, h:mm a"
                cell.createdTimeLabel.text =  dateFormatter.string(from: localDate)
                
                for user in users where user.uid == group.messages[indexPath.row].sender {
                    let url = URL(string: user.userAvatar)
                    cell.avatarImageView.kf.indicatorType = .activity
                    cell.avatarImageView.kf.setImage(with: url)
                    sender = user
                }
                
                cell.avatarHandler = {
                    
                    if group.messages[indexPath.row].sender != uid {
                        let storyBoard = UIStoryboard(name: "Profile", bundle: nil)
                        guard let vc =  storyBoard.instantiateViewController(withIdentifier: "OtherProfileViewController") as? OtherProfileViewController else { return }
                        vc.userInThisPage = sender
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        self.tabBarController?.selectedIndex = 4
                    }
                    
                }

                
                return cell
              
            } else {
                
                let leftImageTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LeftImageTableViewCell", for: indexPath)
                guard let cell = leftImageTableViewCell as? LeftImageTableViewCell else { return leftImageTableViewCell }
                var sender: User?
                let url = URL(string:group.messages[indexPath.row].image ?? "")
                cell.messageImage.kf.indicatorType = .activity
                cell.messageImage.kf.setImage(with: url)
                let localDate = group.messages[indexPath.row].createdTime
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d, h:mm a"
                cell.createdTimeLabel.text =  dateFormatter.string(from: localDate)
                
                for user in users where user.uid == group.messages[indexPath.row].sender {
                    let url = URL(string: user.userAvatar)
                    cell.avatarImageView.kf.indicatorType = .activity
                    cell.avatarImageView.kf.setImage(with: url)
                    sender = user
                }
                
                cell.imageHandler = {
                    
                    let vc = ImageViewerViewController()
                    guard let image = group.messages[indexPath.row].image else { return }
                    vc.images.append(image)
                    vc.currentPage = 0
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }
                
                cell.avatarHandler = {
                    
                    if group.messages[indexPath.row].sender != uid {
                        let storyBoard = UIStoryboard(name: "Profile", bundle: nil)
                        guard let vc =  storyBoard.instantiateViewController(withIdentifier: "OtherProfileViewController") as? OtherProfileViewController else { return }
                        vc.userInThisPage = sender
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        self.tabBarController?.selectedIndex = 4
                    }
                    
                }
                
                return cell
            
            }
        }
    }
}
