//
//  OtherProfileViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/5/4.
//

import UIKit
import Kingfisher

class OtherProfileViewController: UIViewController {
    
    @IBOutlet weak var userAvatar: UIImageView!
    
    @IBOutlet weak var followersListButton: UIButton!
    
    @IBOutlet weak var followersLabel: UILabel!
    
    @IBOutlet weak var followingsListButton: UIButton!
    
    @IBOutlet weak var followingsLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var contentTableView: UITableView!
    
    // User Data Source
    var currentUser: User?
    var userInThisPage: User?
    var users: [User] = []
    var isFollowing = false
    
    // Note Data Source
    var notes: [Note] = []
    
    // Group Data Source
    var groups: [Group] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Block User Button
        let ellipsisButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(openActionList))
        self.navigationItem.rightBarButtonItem = ellipsisButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh segment control selected index
        segmentControl.selectedSegmentIndex = 0
        
        // Fetch Users
        fetchUsers()
        
        // Nav Bar title
        self.navigationItem.title = "\(userInThisPage?.email ?? "")"
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        configureLayout()
        
        configureTableView()
        
    }
    
    // Segment Changes
    
    @IBAction func changeSegment(_ sender: Any) {
        
        contentTableView.reloadData()
        
    }
    
    // Follow User
    
    @IBAction func followUser(_ sender: Any) {
        
        if isFollowing == false {
            
            currentUser?.followings.append(userInThisPage?.uid ?? "")
            
            userInThisPage?.followers.append(currentUser?.uid ?? "")
            
        } else {
            
            guard let currentUser = currentUser else {
                return
            }
            
            guard let userInThisPage = userInThisPage else {
                return
            }

            self.currentUser?.followings = currentUser.followings.filter { $0 != userInThisPage.uid }
            
            self.userInThisPage?.followers = userInThisPage.followers.filter { $0 != currentUser.uid }
            
        }
        
        guard let currentUser = currentUser else {
            return
        }
        
        UserManager.shared.updateUser(user: currentUser, uid: currentUser.uid) { result in
            
            switch result {
                
            case .success:
                
                guard let userInThisPage = self.userInThisPage else {
                    return
                }
                
                UserManager.shared.updateUser(user: userInThisPage, uid: userInThisPage.uid) { result in
                    
                    switch result {
                        
                    case .success:
                        
                        self.fetchUsers()
                        
                        print("被追蹤成功")
                        
                    case .failure:
                        
                        print("被追蹤失敗")
                        
                    }
                }
                
                print("追蹤成功")
                
            case .failure:
                
                print("追蹤失敗")
                
            }
        }
        
    }
    
}

extension OtherProfileViewController {
    
    @objc private func openActionList() {
        
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "封鎖用戶", style: .default) { action in
            self.blockUser()
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
        
        self.present(controller, animated: true)
        
    }
    
}

// Configure DataSource
extension OtherProfileViewController {
    
    func configureTableView() {
        
        contentTableView.dataSource = self
//        contentTableView.delegate = self
        contentTableView.registerCellWithNib(identifier: String(describing: PersonalNoteTableViewCell.self), bundle: nil)
        contentTableView.registerCellWithNib(identifier: String(describing: PersonalGroupTableViewCell.self), bundle: nil)
        
    }
    
    func configureLayout() {
        
        userAvatar.layer.cornerRadius = userAvatar.frame.width / 2
        nameLabel.font = UIFont(name: "PingFangTC-Regular", size: 16)
        followersListButton.titleLabel?.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        followersListButton.tintColor = .black
        followersLabel.font = UIFont(name: "PingFangTC-Regular", size: 16)
        followingsListButton.titleLabel?.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        followingsListButton.tintColor = .black
        followingsLabel.font = UIFont(name: "PingFangTC-Regular", size: 16)
        followButton.titleLabel?.font = UIFont(name: "PingFangTC-Regular", size: 16)
        followButton.layer.cornerRadius = 10
        followButton.clipsToBounds = true
        
        segmentControl.backgroundColor = .clear
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.myDarkGreen], for: .normal)
        segmentControl.selectedSegmentTintColor = .myDarkGreen
        
    }
    
    func configureUserDetail() {
        
        guard let user = userInThisPage else { return }
        let url = URL(string: user.userAvatar)
        userAvatar.kf.indicatorType = .activity
        userAvatar.kf.setImage(with: url)
        nameLabel.text = user.userName
        followersListButton.setTitle("\(user.followers.count)", for: .normal)
        followingsListButton.setTitle("\(user.followings.count)", for: .normal)
        
        if isFollowing == true {
            followButton.backgroundColor = .white
            followButton.layer.borderWidth = 1
            followButton.tintColor = .black
            followButton.layer.borderColor = UIColor.black.cgColor
            followButton.setTitle("追蹤中", for: .normal)
        } else {
            followButton.backgroundColor = .myDarkGreen
            followButton.tintColor = .white
            followButton.layer.borderColor = UIColor.clear.cgColor
            followButton.setTitle("追蹤", for: .normal)
        }
        
    }
    
}

// Firebase functions
extension OtherProfileViewController {
    
    private func blockUser() {
        
        currentUser?.blockUsers.append(userInThisPage?.uid ?? "")
        
        guard let currentUser = currentUser else { return }
        
        UserManager.shared.updateUser(user: currentUser, uid: currentUser.uid) { result in
            
            switch result {
                
            case .success:
                let controller = UIAlertController(title: "封鎖成功", message: nil, preferredStyle: .alert)
                let action = UIAlertAction(title: "返回首頁", style: .default) { action in
                    self.navigationController?.popToRootViewController(animated: true)
                }
                controller.addAction(action)
                self.present(controller, animated: true)
                
                print("封鎖成功")
                
            case .failure:
                
                print("封鎖失敗")
                
            }
        }
        
    }
    
    private func fetchUsers() {
        
        UserManager.shared.fetchUsers { result in
            switch result {
                
            case .success(let existingUser):
                
                self.users = existingUser
                
                for user in self.users where user.uid == FirebaseManager.shared.currentUser?.uid {
                    self.currentUser = user
                }
                
                guard let followings = self.currentUser?.followings else { return }
                self.isFollowing = false
                for following in followings where following == self.userInThisPage?.uid {
                    self.isFollowing = true
                }
                
                self.fetchNotes()
                
                DispatchQueue.main.async {
                    
                    self.configureUserDetail()
                    
                }
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
        
    }
    
    private func fetchNotes() {
        
        NoteManager.shared.fetchNotes { result in
            switch result {
                
            case .success(let notes):
                
                for userNote in self.userInThisPage?.userNotes ?? [] {
                    
                    self.notes = notes.filter{ $0.noteId == userNote }
                    
                }
                
                self.fetchGroups()
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
        
    }
    
    private func fetchGroups() {
        
        GroupManager.shared.fetchGroups { result in
            switch result {
                
            case .success(let groups):
                
                for userGroup in self.userInThisPage?.userGroups ?? [] {
                    
                    self.groups = groups.filter{ $0.groupId == userGroup }
                    
                }
                
                DispatchQueue.main.async {
                    
                    self.contentTableView.reloadData()
                    
                }
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
        
    }
    
}

// Tableview Data Source
extension OtherProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentControl.selectedSegmentIndex == 0 {
            return notes.count
        } else {
            return groups.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if segmentControl.selectedSegmentIndex == 0 {
            
            let personalNoteTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PersonalNoteTableViewCell", for: indexPath)
            guard let cell = personalNoteTableViewCell as? PersonalNoteTableViewCell else { return personalNoteTableViewCell }
            let url = URL(string: notes[indexPath.row].cover)
            cell.mainImageView.kf.indicatorType = .activity
            cell.mainImageView.kf.setImage(with: url)
            
            // querying users' name & avatar
            for user in users where user.uid == notes[indexPath.row].authorId {
                cell.nameLabel.text = user.userName
                let url = URL(string: user.userAvatar)
                cell.avatarImageView.kf.indicatorType = .activity
                cell.avatarImageView.kf.setImage(with: url)
            }
            
            cell.titleLabel.text = notes[indexPath.row].title
            return cell
            
        } else {
            
            let personalGroupTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PersonalGroupTableViewCell", for: indexPath)
            guard let cell = personalGroupTableViewCell as? PersonalGroupTableViewCell else { return personalGroupTableViewCell }
            let url = URL(string: groups[indexPath.row].groupCover)
            cell.coverImage.kf.indicatorType = .activity
            cell.coverImage.kf.setImage(with: url)
            
            // querying users' name & avatar
            for user in users where user.uid == groups[indexPath.row].groupOwner {
                cell.nameLabel.text = user.userName
                let url = URL(string: user.userAvatar)
                cell.avatarImage.kf.indicatorType = .activity
                cell.avatarImage.kf.setImage(with: url)
            }
            let date = groups[indexPath.row].createdTime
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            cell.dateLabel.text = formatter.string(from: date)
            cell.titleLabel.text = groups[indexPath.row].groupTitle
            cell.memberCountsLabel.text = "\(groups[indexPath.row].groupMembers.count)"
            return cell
        }
    }
    
}
