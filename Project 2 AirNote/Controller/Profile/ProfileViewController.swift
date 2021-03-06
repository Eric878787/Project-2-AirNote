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
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var renameButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingsButton: UIButton!
    @IBOutlet weak var followingsLabel: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var noteTableView: UITableView!
    @IBOutlet weak var groupTableView: UITableView!
    @IBOutlet weak var categorySegmentControl: UISegmentedControl!
    
    // Select Image
    let imagePickerController = UIImagePickerController()
    
    // User Data
    private (set) var users: [User] = []
    private (set) var currentUser: User?
    private (set) var blockedUsers: [User] = []
    private (set) var followings: [User] = []
    private (set) var followers: [User] = []
    
    // Note Data
    private (set) var notes: [Note] = []
    private (set) var savedNotes: [Note] = []
    private (set) var ownedNotes: [Note] = []
    let noteCategories: [NoteCategory] = [.ownedNote, .savedNote]
    
    // Group Data
    private (set) var groups: [Group] = []
    private (set) var savedGroups: [Group] = []
    private (set) var ownedGroups: [Group] = []
    let groupCategories: [GroupCategory] = [.ownedGroup, .savedGroup]
    
    //    let dict: [ContentCategory: [Group]]
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGesture()
        imagePickerController.delegate = self
        configureNavigationBar()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUsers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureComponents()
    }
    
    // MARK: Methods
    func configureNavigationBar() {
        let logOutButton = UIBarButtonItem(image: UIImage(systemName: "arrowshape.turn.up.forward.fill"),
                                           style: .plain,
                                           target: self, action: #selector(signOut))
        self.navigationItem.leftBarButtonItem = logOutButton
        
        let blockListButton = UIBarButtonItem(image: UIImage(systemName: "person.fill.badge.minus"),
                                              style: .plain, target: self,
                                              action: #selector(toBlockList))
        self.navigationItem.rightBarButtonItem =  blockListButton
    }
    
    @IBAction func settingName(_ sender: Any) {
        
        let controller = UIAlertController(title: "??????", message: "?????????????????????", preferredStyle: .alert)
        controller.addTextField { textField in
            textField.placeholder = "??????"
        }
        
        let action = UIAlertAction(title: "??????", style: .default) { [unowned controller] _ in
            
            guard let textField = controller.textFields?[0] else { return }
            self.currentUser?.userName = textField.text != "" ? textField.text! : "?????????"
            LKProgressHUD.show()
            self.updateUserName()
            
        }
        
        action.setValue(UIColor.black, forKey: "titleTextColor")
        controller.addAction(action)
        self.present(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func didTapCamera(_ sender: UIButton) {
        showChoosePhotoAlert(imagePickerController)
    }
    
    @IBAction func didTouchFollowerButton(_ sender: UIButton) {
        guard let viewController =
                UIStoryboard.profile.instantiateViewController(withIdentifier: "FollwerFollowingListViewController")
                as? FollwerFollowingListViewController else { return }
        viewController.userList = self.followers
        viewController.navItemTitle = "????????????"
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func didTouchFollowingButton(_ sender: UIButton) {
        guard let viewController =
                UIStoryboard.profile.instantiateViewController(withIdentifier: "FollwerFollowingListViewController")
                as? FollwerFollowingListViewController else { return }
        viewController.userList = self.followings
        viewController.navItemTitle = "????????????"
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func didChangeSegment(_ sender: UISegmentedControl) {
        let didSelectNote = sender.selectedSegmentIndex == 0
        noteTableView.isHidden = !didSelectNote
        groupTableView.isHidden = didSelectNote
        
    }
    
}

// AvatarImage Selection
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func addTapGesture() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(imageTapped(tapGestureRecognizer:)))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    @objc private func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        
        guard tapGestureRecognizer.view
                as? UIImageView != nil else { return }
        
        showChoosePhotoAlert(imagePickerController)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [ UIImagePickerController.InfoKey: Any ]) {
        
        if let image = info[.originalImage] as? UIImage {
            
            DispatchQueue.main.async {
                LKProgressHUD.show()
                self.avatarImageView.image = image
            }
            uploadUserAvatar()
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
        noteTableView.register(DeleteAccountTableViewCell.self,
                               forCellReuseIdentifier: DeleteAccountTableViewCell.reuseIdentifier)
        
        groupTableView.dataSource = self
        groupTableView.delegate = self
        groupTableView.separatorStyle = .none
        groupTableView.register(GroupHeader.self, forHeaderFooterViewReuseIdentifier: GroupHeader.reuseIdentifier)
        groupTableView.registerCellWithNib(identifier: String(describing: PersonalGroupTableViewCell.self), bundle: nil)
        groupTableView.register(DeleteAccountTableViewCell.self,
                                forCellReuseIdentifier: DeleteAccountTableViewCell.reuseIdentifier)
        
    }
    
}

// Layouting Label & Button
extension ProfileViewController {
    
    func refreshUserInfo() {
        // Profile Avatar
        let url = URL(string: currentUser?.userAvatar ?? "")
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(with: url)
        
        // User Name
        if currentUser?.userName != "" {
            nameLabel.text = currentUser?.userName
        } else {
            nameLabel.text = currentUser?.email
        }
        
        // User Followers
        followersButton.setTitle("\(currentUser?.followers.count ?? 0)", for: .normal)
        
        // User Followings
        followingsButton.setTitle("\(currentUser?.followings.count ?? 0)", for: .normal)
        
    }
    
    func configureComponents() {
        
        // Avatar Image View
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        avatarImageView.clipsToBounds = true
        
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
        followersButton.titleLabel?.font = UIFont(name: "PingFangTC-Semibold", size: 16) // constant
        followersButton.tintColor = .black
        
        // Configure Followings Label
        setUpBasicLabel(followingsLabel)
        
        // Configure Followings Button
        followingsButton.titleLabel?.font = UIFont(name: "PingFangTC-Semibold", size: 16)
        followingsButton.tintColor = .black
        
        // Configure Segment Control
        setUpBasicSegmentControl(categorySegmentControl)
        
    }
    
}

// Remote Data
extension ProfileViewController {
    
    @objc func signOut() {
        showAlternativeAlert("???????????????", nil, {
            self.confirmToSignOut()
        }, {
            return
        })
    }
    
    private func confirmToSignOut() {
        self.showBasicConfirmationAlert("????????????", "?????????????????????") {
            FirebaseManager.shared.signout()
            if self.presentingViewController == nil {
                guard let viewController = UIStoryboard.auth.instantiateInitialViewController() else { return }
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true)
            } else {
                self.dismiss(animated: true)
            }
        }
    }
    
    @objc func toBlockList() {
        guard let viewController =
                UIStoryboard.profile.instantiateViewController(withIdentifier: "BlockListViewController")
                as? BlockListViewController else { return }
        viewController.user = self.currentUser
        viewController.blockList = self.blockedUsers
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    private func fetchUsers() {
        LKProgressHUD.show()
        UserManager.shared.fetchUsers { result in
            switch result {
                
            case .success(let existingUser):
                self.users = existingUser
                for user in self.users where user.uid == FirebaseManager.shared.currentUser?.uid {
                    self.currentUser = user
                }
                
                let allUsers = self.users
                guard let blockedUids = self.currentUser?.blockUsers else { return }
                self.filterBlockedUsers(blockedUids, allUsers)
                
                // Filter Follwings
                guard let followingsUids = self.currentUser?.followings else { return }
                self.filterFollwings(followingsUids, allUsers)
                
                // Filter Follwers
                guard let followerUids = self.currentUser?.followers else { return }
                self.filterFollwers(followerUids, allUsers)
                
                DispatchQueue.main.async {
                    self.fetchNotesAndGroups()
                    self.refreshUserInfo()
                    LKProgressHUD.dismiss()
                }
                
            case .failure:
                self.showBasicConfirmationAlert("??????????????????", "?????????????????????")
            }
        }
    }
    
    func filterBlockedUsers(_ blockedUids: [String], _ allUsers: [User]) { // Using Map Function
        self.blockedUsers = []
        for blockedUid in blockedUids {
            self.blockedUsers += allUsers.filter { $0.uid == blockedUid }
        }
    }
    
    func filterFollwings(_ followingsUids: [String], _ allUsers: [User]) {
        self.followings = []
        for followingsUid in followingsUids {
            self.followings += allUsers.filter { $0.uid == followingsUid }
        }
    }
    
    func filterFollwers(_ followerUids: [String], _ allUsers: [User]) {
        self.followers = []
        for followerUid in followerUids {
            self.followers += allUsers.filter { $0.uid == followerUid }
        }
    }
    
    private func uploadUserAvatar() {
        guard let image = avatarImageView.image else { return }
        UserManager.shared.uploadPhoto(image: image) { result in
            switch result {
            case .success(let url):
                self.currentUser?.userAvatar = "\(url)"
                self.uploadUserAvatar()
            case .failure:
                self.showBasicConfirmationAlert("??????????????????", "?????????????????????")
            }
        }
    }
    
    private func updateUserAvatar() {
        guard let user = self.currentUser else { return }
        UserManager.shared.updateUser(user: user, uid: FirebaseManager.shared.currentUser?.uid ?? "") { result in
            switch result {
            case .success:
                self.showBasicConfirmationAlert("??????????????????", nil) {
                    self.fetchUsers()
                }
            case .failure:
                self.showBasicConfirmationAlert("??????????????????", "?????????????????????")
            }
        }
    }
    
    private func updateUserName() {
        guard let user = self.currentUser else { return }
        LKProgressHUD.show()
        UserManager.shared.updateUser(user: user, uid: FirebaseManager.shared.currentUser?.uid ?? "") { result in
            switch result {
            case .success:
                self.showBasicConfirmationAlert("??????????????????", "") {
                    self.fetchUsers()
                }
            case .failure:
                self.showBasicConfirmationAlert("??????????????????", "?????????????????????")
            }
        }
    }
    
    private func fetchNotesAndGroups() {
        let group = DispatchGroup()
        var didFetchSuccess: [Bool] = []
        group.enter()
        fetchNotes { result in
            didFetchSuccess.append(result)
            group.leave()
        }
        group.enter()
        fetchGroups { result in
            didFetchSuccess.append(result)
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) {
            if didFetchSuccess.contains(false) {
                return
            } else {
                self.noteTableView.reloadData()
                self.groupTableView.reloadData()
            }
        }
    }
    
    private func fetchNotes(_ completion: @escaping (Bool) -> Void) {
        NoteManager.shared.fetchNotes { result in
            switch result {
                
            case .success(let notes):
                
                self.savedNotes = []
                for savedNote in self.currentUser?.savedNotes ?? [] {
                    self.savedNotes += notes.filter { $0.noteId == savedNote }
                }
                
                self.ownedNotes = []
                for userNote in self.currentUser?.userNotes ?? [] {
                    self.ownedNotes += notes.filter { $0.noteId == userNote }
                }
                
                // Filter Blocked Users Content
                guard let blockedUids = self.currentUser?.blockUsers else { return }
                for blockedUid in blockedUids {
                    self.savedNotes = self.savedNotes.filter { $0.authorId != blockedUid }
                }
                
                completion(true)
                
            case .failure:
                self.showBasicConfirmationAlert("??????????????????", "?????????????????????")
                
                completion(false)
            }
        }
    }
    
    private func fetchGroups(_ completion: @escaping (Bool) -> Void) {
        GroupManager.shared.fetchGroups { result in
            switch result {
                
            case .success(let groups):
                
                self.savedGroups = []
                for joinedGroup in self.currentUser?.joinedGroups ?? [] {
                    self.savedGroups += groups.filter { $0.groupId == joinedGroup }
                }
                
                self.ownedGroups = []
                for userGroup in self.currentUser?.userGroups ?? [] {
                    self.ownedGroups += groups.filter { $0.groupId == userGroup }
                }
                
                // Filter Blocked Users Content
                guard let blockedUids = self.currentUser?.blockUsers else { return }
                for blockedUid in blockedUids {
                    self.savedGroups = self.savedGroups.filter { $0.groupOwner != blockedUid }
                }
                
                completion(true)
                
            case .failure:
                self.showBasicConfirmationAlert("??????????????????", "?????????????????????")
                
                completion(false)
            }
        }
    }
    
    private func deleteAccount() { //
        showAlternativeAlert("?????????????????????", "????????????????????????????????????", {
            self.confirmDeletion()
        }, {
            return
        })
    }
    
    private func confirmDeletion() {
        FirebaseManager.shared.delete() // completion
        FirebaseManager.shared.deleteAccountSuccess = {
            guard let uid = FirebaseManager.shared.currentUser?.uid else { return }
            UserManager.shared.deleteUser(uid: uid) { result in
                switch result {
                case .success:
                    self.showBasicConfirmationAlert("??????????????????", "???????????????") {
                        if self.presentingViewController == nil {
                            guard let viewController =
                                    UIStoryboard.auth.instantiateInitialViewController()
                            else {
                                return
                            }
                            viewController.modalPresentationStyle = .fullScreen
                            self.present(viewController, animated: true)
                        } else {
                            self.dismiss(animated: true)
                        }
                    }
                case .failure:
                    self.showBasicConfirmationAlert("??????????????????", "???????????????", nil)
                }
            }
        }
    }
    
    //
}

// Set Up Table View delegate & datasource
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate, DeleteAccountDelegate {
    
    func tapDeleteAccountButton() {
        deleteAccount()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == noteTableView {
            return noteCategories.count + 1
        } else {
            return groupCategories.count + 1
        }
    }
    
    // enum Gasoline
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
        if indexPath.section != 2 {
            if tableView == noteTableView {
                let notesData = [ownedNotes, savedNotes]
                return noteCategories[indexPath.section].cellForIndexPath(indexPath,
                                                                          noteTableView,
                                                                          notesData[indexPath.section],
                                                                          users)
            } else {
                let groupsData = [ownedGroups, savedGroups]
                return groupCategories[indexPath.section].cellForIndexPath(indexPath,
                                                                           groupTableView,
                                                                           groupsData[indexPath.section],
                                                                           users)
            }
        } else {
            let deleteAccountTableViewCell =
            tableView.dequeueReusableCell(withIdentifier: DeleteAccountTableViewCell.reuseIdentifier,
                                          for: indexPath)
            guard let cell = deleteAccountTableViewCell
                    as? DeleteAccountTableViewCell else { return deleteAccountTableViewCell }
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if tableView == noteTableView {
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NoteHeader.reuseIdentifier)
                    as? NoteHeader else { return nil }
            if section != 2 {
                header.title.text = noteCategories[section].title()
                return header
            } else {
                return nil
            }
            
        } else {
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: GroupHeader.reuseIdentifier)
                    as? GroupHeader else { return nil }
            if section != 2 {
                header.title.text = groupCategories[section].title()
                return header
            } else {
                return nil
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == noteTableView {
            let storyboard = UIStoryboard(name: "NotesDetail", bundle: nil)
            guard let viewController = storyboard.instantiateViewController(withIdentifier: "NoteDetailViewController")
                    as? NoteDetailViewController else { return }
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
                    viewController.note = note
                    viewController.comments = note.comments
                    viewController.users = self?.users ?? []
                    viewController.currentUser = self?.currentUser
                    self?.navigationController?.pushViewController(viewController, animated: true)
                case .failure:
                    self?.showBasicConfirmationAlert("??????????????????", "?????????????????????")
                }
            }
            // wrap to be a function
        } else if tableView == groupTableView {
            let storyboard = UIStoryboard(name: "GroupDetail", bundle: nil)
            guard let viewController = storyboard.instantiateViewController(withIdentifier: "GroupDetailViewController")
                    as? GroupDetailViewController else { return }
            let group: Group?
            if indexPath.section == 0 {
                group = ownedGroups[indexPath.row]
            } else if indexPath.section == 1 {
                group = savedGroups[indexPath.row]
                
            } else {
                return
            }
            guard let group = group else { return }
            viewController.group = group
            viewController.users = users
            viewController.user = currentUser
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
