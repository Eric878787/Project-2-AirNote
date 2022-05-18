//
//  ProfileViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/24.
//

import UIKit
import Kingfisher

class ProfileViewController: BaseViewController {
    
    // MARK: Properties
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var renameButton: UIButton!
    
    @IBOutlet weak var followersButton: UIButton!
    
    @IBOutlet weak var followersLabel: UILabel!
    
    @IBOutlet weak var followingsButton: UIButton!
    
    @IBOutlet weak var followingsLabel: UILabel!
    
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var noteTableView: UITableView!
    
    @IBOutlet weak var groupTableView: UITableView!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    // Select Image
    private let imagePickerController = UIImagePickerController()
    
    private var avatarImage: UIImage?
    
    // User Data
    private var users: [User] = []
    
    private var user: User?
    
    private var blockedUsers: [User] = []
    
    private var followings: [User] = []
    
    private var followers: [User] = []
    
    // Note Data
    private var notes: [Note] = []
    
    private var savedNotes: [Note] = []
    
    private var ownedNotes: [Note] = []
    
    private let noteCategories: [ContentCategory] = [.ownedNote, .savedNote]
    
    // Group Data
    private var groups: [Group] = []
    
    private var savedGroups: [Group] = []
    
    private var ownedGroups: [Group] = []
    
    private let groupCategories: [ContentCategory] = [.ownedGroup, .savedGroup]
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Avatar Image Picker
        addTapGesture()
        imagePickerController.delegate = self
        
        // Configure Nav Bar
        configureNavigationBar()
        
        // Configure Table View
        configureTableView()
        
        // Default segment
        noteTableView.isHidden = false
        groupTableView.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUsers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Configure Components
        configureComponents()
        
    }
    
    // MARK: Methods
    func configureNavigationBar() {
        // Log out Button
        let logOutButton = UIBarButtonItem(image: UIImage(systemName: "arrowshape.turn.up.forward.fill"), style: .plain, target: self, action: #selector(signOut))
        self.navigationItem.leftBarButtonItem = logOutButton
        
        // Block List
        let blockListButton = UIBarButtonItem(image: UIImage(systemName: "person.fill.badge.minus"), style: .plain, target: self, action: #selector(toBlockList))
        self.navigationItem.rightBarButtonItem =  blockListButton
    }
    
    @IBAction func settingName(_ sender: Any) {
        
        let controller = UIAlertController(title: "暱稱", message: "請輸入你的暱稱", preferredStyle: .alert)
        controller.addTextField { textField in
            textField.placeholder = "暱稱"
        }
        
        let action = UIAlertAction(title: "確認", style: .default) { [unowned controller] _ in
            
            self.user?.userName = controller.textFields?[0].text ?? ""
            LKProgressHUD.show()
            self.updateUserName()
            
        }
        
        action.setValue(UIColor.black, forKey: "titleTextColor")
        controller.addAction(action)
        self.present(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        initChoosePhotoAlert(imagePickerController)
    }
    
    @IBAction func followerTouched(_ sender: Any) {
        guard let vc = UIStoryboard.profile.instantiateViewController(withIdentifier: "FollwerFollowingListViewController") as? FollwerFollowingListViewController else { return }
        vc.userList = self.followers
        vc.navItemTitle = "粉絲名單"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func followingToched(_ sender: Any) {
        guard let vc = UIStoryboard.profile.instantiateViewController(withIdentifier: "FollwerFollowingListViewController") as? FollwerFollowingListViewController else { return }
        vc.userList = self.followings
        vc.navItemTitle = "追蹤名單"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func changeSegment(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            noteTableView.isHidden = false
            groupTableView.isHidden = true
        } else {
            noteTableView.isHidden = true
            groupTableView.isHidden = false
        }
        
    }
    
}

// AvatarImage Selection
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func addTapGesture() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        avatar.isUserInteractionEnabled = true
        avatar.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    @objc private func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        
        guard let tappedImage = tapGestureRecognizer.view as? UIImageView else { return }
        
        initChoosePhotoAlert(imagePickerController)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            
            DispatchQueue.main.async {
                LKProgressHUD.show()
            }
            avatarImage = image
            avatar.image = avatarImage
            updateUserAvatar()
        }
        
        picker.dismiss(animated: true)
        
    }
    
}

// Configure Tableview
extension ProfileViewController {
    
    func configureTableView() {
        
        noteTableView.dataSource = self
        noteTableView.delegate = self
        noteTableView.separatorStyle = .none
        noteTableView.register(NoteHeader.self, forHeaderFooterViewReuseIdentifier: NoteHeader.reuseIdentifier)
        noteTableView.registerCellWithNib(identifier: String(describing: PersonalNoteTableViewCell.self), bundle: nil)
        noteTableView.register(DeleteAccountTableViewCell.self, forCellReuseIdentifier: DeleteAccountTableViewCell.reuseIdentifier)
        
        groupTableView.dataSource = self
        groupTableView.delegate = self
        groupTableView.separatorStyle = .none
        groupTableView.register(GroupHeader.self, forHeaderFooterViewReuseIdentifier: GroupHeader.reuseIdentifier)
        groupTableView.registerCellWithNib(identifier: String(describing: PersonalGroupTableViewCell.self), bundle: nil)
        groupTableView.register(DeleteAccountTableViewCell.self, forCellReuseIdentifier: DeleteAccountTableViewCell.reuseIdentifier)
        
    }
    
}

// Layouting Label & Button
extension ProfileViewController {
    
    func refreshUserInfo() {
        
        // Profile Avatar
        let url = URL(string: user?.userAvatar ?? "")
        avatar.kf.indicatorType = .activity
        avatar.kf.setImage(with: url)
        
        // User Name
        if user?.userName != "" {
            nameLabel.text = user?.userName
        } else {
            nameLabel.text = user?.email
        }
        
        // User Followers
        followersButton.setTitle("\(user?.followers.count ?? 0)", for: .normal)
        
        // User Followings
        followingsButton.setTitle("\(user?.followings.count ?? 0)", for: .normal)
        
    }
    
    func configureComponents() {
        
        // Avatar Image View
        avatar.layer.cornerRadius = avatar.frame.height / 2
        avatar.clipsToBounds = true
        
        // Plus Image
        cameraButton.layer.cornerRadius = cameraButton.frame.height / 2
        cameraButton.tintColor = .white
        cameraButton.layer.borderColor = UIColor.white.cgColor
        cameraButton.layer.borderWidth = 1
        cameraButton.backgroundColor = .myDarkGreen
        
        // Configure Rename Button
        renameButton.tintColor = .myDarkGreen
        
        // Configure Followers Label
        setUpBasicLabel(followersLabel)
        
        // Configure Followers Button
        followersButton.titleLabel?.font = UIFont(name: "PingFangTC-Semibold", size: 16)
        followersButton.tintColor = .black
        
        // Configure Followings Label
        setUpBasicLabel(followingsLabel)
        
        // Configure Followings Button
        followingsButton.titleLabel?.font = UIFont(name: "PingFangTC-Semibold", size: 16)
        followingsButton.tintColor = .black
        
        // Configure Segment Control
        setUpBasicSegmentControl(segmentControl)

    }
    
}

// Remote Data
extension ProfileViewController {
    
    @objc func signOut() {
        initAlternativeAlert("是否要登出", nil, {
            self.conformToSignOut()
        }, {
            return
        })
    }
    
    private func conformToSignOut() {
        self.initBasicConfirmationAlert("登出成功", "將返回登入頁面") {
            FirebaseManager.shared.signout()
            if self.presentingViewController == nil {
                guard let vc = UIStoryboard.auth.instantiateInitialViewController() else { return }
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            } else {
                self.dismiss(animated: true)
            }
        }
    }
    
    @objc func toBlockList() {
        guard let vc = UIStoryboard.profile.instantiateViewController(withIdentifier: "BlockListViewController") as? BlockListViewController else { return }
        vc.user = self.user
        vc.blockList = self.blockedUsers
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    private func fetchUsers() {
        
        LKProgressHUD.show()
        
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
                
                // Filter Follwings
                guard let followingsUids = self.user?.followings else { return }
                self.followings = []
                for followingsUid in followingsUids {
                    self.followings += allUsers.filter{$0.uid == followingsUid}
                }
                
                // Filter Follwers
                guard let followerUids = self.user?.followers else { return }
                self.followers = []
                for followerUid in followerUids {
                    self.followers += allUsers.filter{$0.uid == followerUid}
                }
                
                DispatchQueue.main.async {
                    self.fetchContent()
                    self.refreshUserInfo()
                    LKProgressHUD.dismiss()
                }
                
            case .failure(let error):
                print("fetchData.failure: \(error)")
            }
        }
        
    }
    
    private func updateUserAvatar() {
        
        let group = DispatchGroup()
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
                    self.initBasicConfirmationAlert("上傳頭貼成功", "") {
                        self.fetchUsers()
                    }
                case .failure:
                    print(result)
                }
            }
        }
        
    }
    
    private func updateUserName() {
        guard let user = self.user else { return }
        LKProgressHUD.show()
        UserManager.shared.updateUser(user: user, uid: FirebaseManager.shared.currentUser?.uid ?? "") { result in
            switch result {
            case .success:
                self.initBasicConfirmationAlert("更新暱稱成功", "") {
                    self.fetchUsers()
                }
            case .failure:
                print(result)
            }
        }
    }
    
    private func fetchContent() {
        
        let group = DispatchGroup()
        group.enter()
        fetchNotes {
            group.leave()
        }
        group.enter()
        fetchGroups {
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) {
            self.noteTableView.reloadData()
            self.groupTableView.reloadData()
        }
        
    }
    
    private func fetchNotes(_ completion: @escaping ()-> Void) {
        
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
                
                completion()
                
            case .failure(let error):
                print("fetchData.failure: \(error)")
            }
        }
        
    }
    
    private func fetchGroups(_ completion: @escaping ()-> Void) {
        
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
                
                completion()
                
            case .failure(let error):
                print("fetchData.failure: \(error)")
            }
        }
        
    }
    
    private func deleteAccount() {
        initAlternativeAlert("是否要刪除帳號", "刪除後將清除所有帳戶資料", {
            self.confirmDeletion()
        }, {
            return
        })
    }
    
    private func confirmDeletion() {
        FirebaseManager.shared.delete()
        FirebaseManager.shared.deleteAccountSuccess = {
            guard let uid = FirebaseManager.shared.currentUser?.uid else { return }
            UserManager.shared.deleteUser(uid: uid) { result in
                switch result {
                case .success:
                    self.initBasicConfirmationAlert("刪除帳號成功", "請重新註冊") {
                        if self.presentingViewController == nil {
                            guard let vc = UIStoryboard.auth.instantiateInitialViewController() else { return }
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true)
                        } else {
                            self.dismiss(animated: true)
                        }
                    }
                case .failure:
                    self.initBasicConfirmationAlert("刪除帳號失敗", "請再次嘗試", nil)
                }
            }
        }
    }
    
}

// Set Up Table View delegate & datasource
extension ProfileViewController:  UITableViewDataSource, UITableViewDelegate, DeleteAccountDelegate {
    
    func tapDeleteAccountButton() {
        deleteAccount()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == noteTableView {
            if section == 0 {
                return ownedNotes.count
            } else if section == 1 {
                return savedNotes.count
            } else {
                return 1
            }
        } else {
            if section == 0 {
                return ownedGroups.count
            } else if section == 1 {
                return savedGroups.count
            } else {
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == noteTableView {
            if indexPath.section == 0 {
                return noteCategories[indexPath.section].cellForIndexPath(indexPath, noteTableView, ownedNotes, [], users)
            } else if indexPath.section == 1 {
                return noteCategories[indexPath.section].cellForIndexPath(indexPath, noteTableView, savedNotes, [], users)
            } else {
                let deleteAccountTableViewCell = tableView.dequeueReusableCell(withIdentifier: DeleteAccountTableViewCell.reuseIdentifier, for: indexPath)
                guard let cell = deleteAccountTableViewCell as? DeleteAccountTableViewCell else { return deleteAccountTableViewCell }
                cell.delegate = self
                return cell
            }
            
        } else {
            if indexPath.section == 0 {
                return groupCategories[indexPath.section].cellForIndexPath(indexPath, groupTableView, [], ownedGroups, users)
            } else if indexPath.section == 1 {
                return groupCategories[indexPath.section].cellForIndexPath(indexPath, groupTableView, [], savedGroups, users)
            } else {
                let deleteAccountTableViewCell = tableView.dequeueReusableCell(withIdentifier: DeleteAccountTableViewCell.reuseIdentifier, for: indexPath)
                guard let cell = deleteAccountTableViewCell as? DeleteAccountTableViewCell else { return deleteAccountTableViewCell }
                cell.delegate = self
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if tableView == noteTableView {
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NoteHeader.reuseIdentifier) as? NoteHeader else { return nil }
            if section == 0 {
                header.title.text = ContentCategory.ownedNote.rawValue
                return header
            } else if section == 1 {
                header.title.text = ContentCategory.savedNote.rawValue
                return header
            } else {
                return nil
            }
            
        } else {
            
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: GroupHeader.reuseIdentifier) as? GroupHeader else { return nil }
            if section == 0 {
                header.title.text = ContentCategory.ownedGroup.rawValue
                return header
            } else if section == 1 {
                header.title.text = ContentCategory.savedGroup.rawValue
                return header
            } else {
                return nil
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == noteTableView {
            let storyboard = UIStoryboard(name: "NotesDetail", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "NoteDetailViewController") as? NoteDetailViewController else { return }
            let note: Note?
            if indexPath.section == 0 {
                ownedNotes[indexPath.row].clicks.append(FirebaseManager.shared.currentUser?.uid ?? "")
                note = ownedNotes[indexPath.row]
            } else if indexPath.section == 1 {
                savedNotes[indexPath.row].clicks.append(FirebaseManager.shared.currentUser?.uid ?? "")
                note = savedNotes[indexPath.row]
                
            } else {
                return
            }
            guard let note = note else { return }
            NoteManager.shared.updateNote(note: note, noteId: note.noteId) { [weak self] result in
                switch result {
                case .success:
                    vc.note = note
                    vc.comments = note.comments
                    vc.users = self?.users ?? []
                    vc.currentUser = self?.user
                    self?.navigationController?.pushViewController(vc, animated: true)
                    
                case .failure(let error):
                    print("fetchData.failure: \(error)")
                }
            }
        } else if tableView == groupTableView {
            let storyboard = UIStoryboard(name: "GroupDetail", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "GroupDetailViewController") as? GroupDetailViewController else { return }
            let group: Group?
            if indexPath.section == 0 {
                group = ownedGroups[indexPath.row]
            } else if indexPath.section == 1 {
                group = savedGroups[indexPath.row]
                
            } else {
                return
            }
            guard let group = group else { return }
            vc.group = group
            vc.users = users
            vc.user = user
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            return
        }
    }
}
