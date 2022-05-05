//
//  ProfileViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/24.
//

import UIKit
import Kingfisher
import SwiftUI

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profilePageTableView: UITableView!
    
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    @IBOutlet weak var profileAvatar: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var settingNameButton: UIButton!
    
    @IBOutlet weak var userFollowersLabel: UILabel!
    
    @IBOutlet weak var userFollowingsLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    // Select Image
    private let imagePickerController = UIImagePickerController()
    
    private var avatarImage: UIImage?
    
    // User Data
    var users: [User] = []
    
    var user: User?
    
    var blockedUsers: [User] = []
    
    // Note Data
    var notes: [Note] = []
    
    var savedNotes: [Note] = []
    
    var ownedNotes: [Note] = []
    
    var notesOnTableView: [Note] = []
    
    var selectedNoteIndex = 0
    
    // Group Data
    var groups: [Group] = []
    
    var savedGroups: [Group] = []
    
    var ownedGroups: [Group] = []
    
    var groupsOnTableView: [Group] = []
    
    var selectedGroupIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Avatar Image Picker
        addTapGesture()
        imagePickerController.delegate = self
        
        // Log out Button
        let deleteButton = UIBarButtonItem(image: UIImage(systemName: "arrowshape.turn.up.forward.fill"), style: .plain, target: self, action: #selector(signOut))
        self.navigationItem.leftBarButtonItem = deleteButton
        
        // Block List
        let blockListButton = UIBarButtonItem(image: UIImage(systemName: "person.fill.badge.minus"), style: .plain, target: self, action: #selector(toBlockList))
        self.navigationItem.rightBarButtonItem =  blockListButton
        
        // Configure Table View
        configureTableView()
        
        // Layout Buttons
        layoutButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUsers()
    }
    
    
    @IBAction func deleteAccount(_ sender: Any) {
        
        FirebaseManager.shared.delete()
        FirebaseManager.shared.deleteAccountSuccess = {
            guard let uid = FirebaseManager.shared.currentUser?.uid else { return }
            UserManager.shared.deleteUser(uid: uid) { result in
                switch result {
                case .success:
                    let controller = UIAlertController(title: "刪除帳號成功", message: "請重新註冊", preferredStyle: .alert)
                    controller.view.tintColor = UIColor.gray
                    let action = UIAlertAction(title: "確認", style: .destructive) { _ in
                        
                        if self.presentingViewController == nil {
                            
                            guard let vc = UIStoryboard.auth.instantiateInitialViewController() else { return }
                            
                            vc.modalPresentationStyle = .fullScreen
                            
                            self.present(vc, animated: true)
                            
                        } else {
                            
                            self.dismiss(animated: true)
                            
                        }
                    }
                    
                    controller.addAction(action)
                    self.present(controller, animated: true)
                    
                case .failure:
                    let controller = UIAlertController(title: "刪除帳號失敗", message: "請再次嘗試", preferredStyle: .alert)
                    controller.view.tintColor = UIColor.gray
                    let action = UIAlertAction(title: "確認", style: .destructive)
                    controller.addAction(action)
                    self.present(controller, animated: true)
                }
            }
        }
        
    }
    
    @IBAction func settingName(_ sender: Any) {
        
        let controller = UIAlertController(title: "暱稱", message: "請輸入你的暱稱", preferredStyle: .alert)
        controller.addTextField { textField in
            textField.placeholder = "暱稱"
        }
        
        let action = UIAlertAction(title: "確認", style: .default) { [unowned controller] _ in
            
            self.user?.userName = controller.textFields?[0].text ?? ""
            self.updateUserName()
            self.layoutLabel()
            
        }
        
        action.setValue(UIColor.black, forKey: "titleTextColor")
        controller.addAction(action)
        self.present(controller, animated: true, completion: nil)
        
    }
    
}

// AvatarImage Selection
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func addTapGesture() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        profileAvatar.isUserInteractionEnabled = true
        profileAvatar.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    @objc private func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        
        guard let tappedImage = tapGestureRecognizer.view as? UIImageView else { return }
        
        let controller = UIAlertController(title: "請上傳頭貼", message: "", preferredStyle: .alert)
        controller.view.tintColor = UIColor.gray
        
        // 相機
        let cameraAction = UIAlertAction(title: "相機", style: .default) { _ in
            self.takePicture()
        }
        controller.addAction(cameraAction)
        
        // 相薄
        let savedPhotosAlbumAction = UIAlertAction(title: "相簿", style: .default) { _ in
            self.openPhotosAlbum()
        }
        controller.addAction(savedPhotosAlbumAction)
        
        // 取消
        let cancelAction = UIAlertAction(title: "取消", style: .destructive, handler: nil)
        controller.addAction(cancelAction)
        
        self.present(controller, animated: true, completion: nil)
        
    }
    
    /// 開啟相機
    func takePicture() {
        imagePickerController.sourceType = .camera
        self.present(imagePickerController, animated: true)
    }
    
    /// 開啟相簿
    func openPhotosAlbum() {
        imagePickerController.sourceType = .savedPhotosAlbum
        self.present(imagePickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            
            avatarImage = image
            
            profileAvatar.image = avatarImage
            
            updateUserAvatar()
            
        }
        
        picker.dismiss(animated: true)
        
    }
    
}

// Configure Tableview
extension ProfileViewController {
    
    func configureTableView() {
        
        profilePageTableView.dataSource = self
        profilePageTableView.delegate = self
        profilePageTableView.registerCellWithNib(identifier: String(describing: PersonalNoteTableViewCell.self), bundle: nil)
        profilePageTableView.registerCellWithNib(identifier: String(describing: PersonalGroupTableViewCell.self), bundle: nil)
        profilePageTableView.register(NoteHeader.self, forHeaderFooterViewReuseIdentifier: NoteHeader.reuseIdentifier)
        profilePageTableView.register(GroupHeader.self, forHeaderFooterViewReuseIdentifier: GroupHeader.reuseIdentifier)
        
        
    }
    
}

// Layouting Label & Button
extension ProfileViewController {
    
    func layoutLabel() {
        
        // Profile Avatar
        if user?.userAvatar != "" {
            let url = URL(string: user?.userAvatar ?? "")
            profileAvatar.kf.indicatorType = .activity
            profileAvatar.kf.setImage(with: url)
            
        } else {
            
            profileAvatar.image = UIImage(systemName: "person.circle")
            
        }
        profileAvatar.layer.cornerRadius = profileAvatar.frame.height / 2
        profileAvatar.clipsToBounds = true
        
        // User Name
        if user?.userName != "" {
            
            userNameLabel.text = user?.userName
            
        } else {
            
            userNameLabel.text = user?.email
            
        }
        
        // User Followers
        userFollowersLabel.text = "Followers:\(user?.followers.count ?? 0)"
        
        // User Followings
        userFollowingsLabel.text = "Followings:\(user?.followings.count ?? 0)"
    }
    
    func layoutButton() {
        
        // Setting Name Button
        settingNameButton.setTitleColor(.white, for: .normal)
        settingNameButton.backgroundColor = .myPurple
        settingNameButton.clipsToBounds = true
        settingNameButton.layer.cornerRadius = 10
        
        // Follow Button
        followButton.isHidden = true
        
        // Configure Delete Account
        deleteAccountButton.setTitle("刪除帳號", for: .normal)
        deleteAccountButton.setTitleColor(.myPurple, for: .normal)
        deleteAccountButton.layer.cornerRadius = 10
        deleteAccountButton.layer.borderWidth = 1
        deleteAccountButton.layer.borderColor = UIColor.myPurple.cgColor
        
    }
    
}


// Fetch Data
extension ProfileViewController {
    
    @objc func signOut() {
        
        FirebaseManager.shared.signout()
        
        if self.presentingViewController == nil {
            
            guard let vc = UIStoryboard.auth.instantiateInitialViewController() else { return }
            
            vc.modalPresentationStyle = .fullScreen
            
            self.present(vc, animated: true)
            
        } else {
            
            self.dismiss(animated: true)
            
        }
        
    }
    
    
    @objc func toBlockList() {
        
        guard let vc = UIStoryboard.profile.instantiateViewController(withIdentifier: "BlockListViewController") as? BlockListViewController else { return }
        vc.user = self.user
        vc.blockList = self.blockedUsers
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    private func fetchUsers() {
        
        UserManager.shared.fetchUsers { result in
            switch result {
                
            case .success(let existingUser):
                
                self.users = existingUser
                
                for user in self.users where user.uid == FirebaseManager.shared.currentUser?.uid {
                    self.user = user
                }
                
                // Filter Blocked Users
                guard let blockedUids = self.user?.blockUsers else { return }
                
                let allUsers = self.users
                
                self.blockedUsers = []
                
                for blockedUid in blockedUids {
                    
                    self.blockedUsers += allUsers.filter{$0.uid == blockedUid}
                    
                }
                
                DispatchQueue.main.async {
                    
                    self.layoutLabel()
                    self.fetchNotes()
                    self.fetchGroups()
                    
                }
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
        
    }
    
    private func updateUserAvatar() {
        
        let group = DispatchGroup()
        let controller = UIAlertController(title: "上傳頭貼成功", message: "", preferredStyle: .alert)
        controller.view.tintColor = UIColor.gray
        
        group.enter()
        guard let image =  avatarImage else { return }
        UserManager.shared.uploadPhoto(image: image) { result in
            switch result {
            case .success(let url):
                self.user?.userAvatar = "\(url)"
                print("\(url)")
            case .failure(let error):
                print("\(error)")
            }
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.global()) {
            guard let user = self.user else { return }
            UserManager.shared.updateUser(user: user, uid: FirebaseManager.shared.currentUser?.uid ?? "") { result in
                switch result {
                case .success:
                    let cancelAction = UIAlertAction(title: "確認", style: .destructive) { _ in
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                    DispatchQueue.main.async {
                        cancelAction.setValue(UIColor.black, forKey: "titleTextColor")
                        controller.addAction(cancelAction)
                        self.present(controller, animated: true, completion: nil)
                    }
                    
                case .failure:
                    print(result)
                }
            }
        }
        
    }
    
    private func updateUserName () {
        let controller = UIAlertController(title: "更新暱稱成功", message: "", preferredStyle: .alert)
        controller.view.tintColor = UIColor.gray
        
        guard let user = self.user else { return }
        UserManager.shared.updateUser(user: user, uid: FirebaseManager.shared.currentUser?.uid ?? "") { result in
            switch result {
            case .success:
                let cancelAction = UIAlertAction(title: "確認", style: .destructive) { _ in
                    self.navigationController?.popViewController(animated: true)
                }
                
                DispatchQueue.main.async {
                    cancelAction.setValue(UIColor.black, forKey: "titleTextColor")
                    controller.addAction(cancelAction)
                    self.present(controller, animated: true, completion: nil)
                }
                
            case .failure:
                print(result)
            }
        }
        
    }
    
    private func fetchNotes() {
        
        NoteManager.shared.fetchNotes { result in
            switch result {
                
            case .success(let notes):
                
                self.savedNotes = []
                
                for savedNote in self.user?.savedNotes ?? [] {
                    
                    self.savedNotes += notes.filter{ $0.noteId == savedNote }
                    
                }
                
                self.ownedNotes = []
                
                for userNote in self.user?.userNotes ?? [] {
                    
                    self.ownedNotes += notes.filter{ $0.noteId == userNote }
                    
                }
                
                // Filter Blocked Users
                guard let blockedUids = self.user?.blockUsers else { return }
                
                for blockedUid in blockedUids {
                    
                    self.users = self.users.filter{$0.uid != blockedUid}
                    
                }
                
                // Filter Blocked Users Content
                
                for blockedUid in blockedUids {
                    
                    self.savedNotes = self.savedNotes.filter{$0.authorId != blockedUid}
                    
                }
                
                // Default datasource of notesOnTableView
                self.wrappingNotes(self.selectedNoteIndex)
                
                self.profilePageTableView.reloadData()
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
        
    }
    
    private func fetchGroups() {
        
        GroupManager.shared.fetchGroups { result in
            switch result {
                
            case .success(let groups):
                
                self.savedGroups = []
                
                for joinedGroup in self.user?.joinedGroups ?? [] {
                    
                    self.savedGroups += groups.filter{ $0.groupId == joinedGroup }
                    
                }
                
                self.ownedGroups = []
                
                for userGroup in self.user?.userGroups ?? [] {
                    
                    self.ownedGroups += groups.filter{ $0.groupId == userGroup }
                    
                }
                
                
                // Filter Blocked Users Content
                guard let blockedUids = self.user?.blockUsers else { return }
                for blockedUid in blockedUids {
                    
                    self.savedGroups = self.savedGroups.filter{ $0.groupOwner != blockedUid} ?? []
                    
                }
                
                // Default datasource of notesOnTableView
                self.wrappingGroups(self.selectedGroupIndex)
                
                self.profilePageTableView.reloadData()
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
        
    }
    
}

// Wrapped Data

extension ProfileViewController {
    
    func wrappingNotes(_ selectedIndex: Int ) {
        
        if selectedIndex == 0 {
            
            notesOnTableView = ownedNotes
            
        } else {
            
            notesOnTableView = savedNotes
            
        }
        
    }
    
    func wrappingGroups(_ selectedIndex: Int ) {
        
        if selectedIndex == 0 {
            
            groupsOnTableView = ownedGroups
            
        } else {
            
            groupsOnTableView = savedGroups
            
        }
        
    }
    
}

// Set Up Table View delegate & datasource
extension ProfileViewController:  UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return notesOnTableView.count
        } else {
            return groupsOnTableView.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let personalNoteTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PersonalNoteTableViewCell", for: indexPath)
            guard let cell = personalNoteTableViewCell as? PersonalNoteTableViewCell else { return personalNoteTableViewCell }
            let url = URL(string: notesOnTableView[indexPath.row].cover)
            cell.mainImageView.kf.indicatorType = .activity
            cell.mainImageView.kf.setImage(with: url)
            
            // querying users' name & avatar
            for user in users where user.uid == notesOnTableView[indexPath.row].authorId {
                cell.nameLabel.text = user.userName
                let url = URL(string: user.userAvatar)
                cell.avatarImageView.kf.indicatorType = .activity
                cell.avatarImageView.kf.setImage(with: url)
            }
            
            cell.titleLabel.text = notesOnTableView[indexPath.row].title
            return cell
            
        } else {
            
            let personalGroupTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PersonalGroupTableViewCell", for: indexPath)
            guard let cell = personalGroupTableViewCell as? PersonalGroupTableViewCell else { return personalGroupTableViewCell }
            let url = URL(string: groupsOnTableView[indexPath.row].groupCover)
            cell.coverImage.kf.indicatorType = .activity
            cell.coverImage.kf.setImage(with: url)
            
            // querying users' name & avatar
            for user in users where user.uid == groupsOnTableView[indexPath.row].groupOwner {
                cell.nameLabel.text = user.userName
                let url = URL(string: user.userAvatar)
                cell.avatarImage.kf.indicatorType = .activity
                cell.avatarImage.kf.setImage(with: url)
            }
            let date = groupsOnTableView[indexPath.row].createdTime
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            cell.dateLabel.text = formatter.string(from: date)
            cell.titleLabel.text = groupsOnTableView[indexPath.row].groupTitle
            cell.memberCountsLabel.text = "\(groupsOnTableView[indexPath.row].groupMembers.count)"
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NoteHeader.reuseIdentifier) as? NoteHeader else { return nil }
            header.firstSegmentController.setTitle("我的筆記", forSegmentAt: 0)
            header.firstSegmentController.setTitle("收藏筆記", forSegmentAt: 1)
            header.firstSegmentHandler = { [weak self] index in
                self?.selectedNoteIndex = index
                self?.wrappingNotes(self?.selectedNoteIndex ?? 0)
                self?.profilePageTableView.reloadData()
            }
            return header
        } else {
            
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: GroupHeader.reuseIdentifier) as? GroupHeader else { return nil }
            header.firstSegmentController.setTitle("我的讀書會", forSegmentAt: 0)
            header.firstSegmentController.setTitle("加入的讀書會", forSegmentAt: 1)
            header.firstSegmentHandler = { [weak self] index in
                self?.selectedGroupIndex = index
                self?.wrappingGroups(self?.selectedGroupIndex ?? 0)
                self?.profilePageTableView.reloadData()
            }
            return header
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        300
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            let storyboard = UIStoryboard(name: "NotesDetail", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "NoteDetailViewController") as? NoteDetailViewController else { return }
            notesOnTableView[indexPath.row].clicks.append(FirebaseManager.shared.currentUser?.uid ?? "")
            NoteManager.shared.updateNote(note: notesOnTableView[indexPath.row], noteId: notesOnTableView[indexPath.row].noteId) { [weak self] result in
                switch result {
                case .success:
                    guard let noteToPass = self?.notesOnTableView[indexPath.row] else { return }
                    vc.note = noteToPass
                    vc.users = self?.users ?? []
                    self?.navigationController?.pushViewController(vc, animated: true)
                    
                case .failure(let error):
                    print("fetchData.failure: \(error)")
                }
            }
            
        } else {
            
            let storyboard = UIStoryboard(name: "GroupDetail", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "GroupDetailViewController") as? GroupDetailViewController else { return }
            vc.group = groupsOnTableView[indexPath.row]
            vc.users = users
            vc.user = user
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
}
