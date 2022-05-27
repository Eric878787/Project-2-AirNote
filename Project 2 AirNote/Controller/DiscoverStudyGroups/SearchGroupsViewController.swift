//
//  SearchGroupsViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/19.
//

import UIKit

class SearchGroupsViewController: BaseViewController {
    
    // MARK: Properties
    private var searchGroupsTableView = UITableView(frame: .zero)
    private var searchController = UISearchController()
    private var groupManager = GroupManager()
    private var userManager = UserManager()
    private var groups: [Group] = []
    private lazy var filteredgroups: [Group] = []
    private var users: [User] = []
    private var user: User?
    private var currentUserId = FirebaseManager.shared.currentUser?.uid
    private var userToBeBlocked = ""
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchGroupsTableView()
        self.navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LKProgressHUD.show()
        fetchGroups()
    }
    
}

// MARK: Protocol UISearchResultsUpdating
extension SearchGroupsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, searchText.isEmpty == false  {
            filteredgroups = groups.filter( { group in
                let keyWord = group.groupKeywords.joined()
                let isInKeyWords = keyWord.localizedStandardContains(searchText)
                let category = group.groupCategory
                let isInCategory = category.localizedStandardContains(searchText)
                let isInTitle = group.groupTitle.localizedStandardContains(searchText)
                let isInAddress = group.location.address.localizedStandardContains(searchText)
                if isInKeyWords || isInCategory || isInTitle || isInAddress == true {
                    return true
                } else {
                    return false
                }
            } )
        } else {
            filteredgroups = groups
        }
        searchGroupsTableView.reloadData()
    }
    
}

// MARK: Configure search result tableview
extension SearchGroupsViewController {
    
    private func configureSearchGroupsTableView() {
        self.searchGroupsTableView.separatorColor = .clear
        searchGroupsTableView.registerCellWithNib(identifier: String(describing: GroupResultTableViewCell.self), bundle: nil)
        searchGroupsTableView.dataSource = self
        searchGroupsTableView.delegate = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        searchGroupsTableView.addGestureRecognizer(longPress)
        view.addSubview(searchGroupsTableView)
        searchGroupsTableView.translatesAutoresizingMaskIntoConstraints = false
        searchGroupsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        searchGroupsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        searchGroupsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        searchGroupsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
    }
    
}

// MARK: Block User
extension SearchGroupsViewController {
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        if sender.state == .began {
            let touchPoint = sender.location(in: searchGroupsTableView)
            if let indexPath = searchGroupsTableView.indexPathForRow(at: touchPoint) {
                userToBeBlocked = filteredgroups[indexPath.row].groupOwner
                openActionList()
            }
        }
    }
    
    @objc private func openActionList() {
        self.showBlockUserAlert {
            self.blockUser()
        }
    }
    
    private func blockUser() {
        guard userToBeBlocked != user?.uid else {
            let controller = UIAlertController(title: "無法封鎖本人帳號", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "確認", style: .default)
            controller.addAction(action)
            self.present(controller, animated: true)
            return
        }
        guard let followers = self.user?.followers else { return }
        guard let followings = self.user?.followings else { return }
        self.user?.followers = followers.filter { $0 != userToBeBlocked}
        self.user?.followings = followings.filter { $0 != userToBeBlocked}
        user?.blockUsers.append(userToBeBlocked)
        guard let currentUser = user else { return }
        UserManager.shared.updateUser(user: currentUser, uid: currentUser.uid) { result in
            switch result {
            case .success:
                self.showBasicConfirmationAlert("封鎖成功", "你將不會再看到此用戶的內容") {
                    self.fetchGroups()
                }
            case .failure:
                self.showBasicConfirmationAlert("封鎖失敗", "請檢查網路連線")
            }
        }
    }
    
}

// MARK: Fetch Data
extension SearchGroupsViewController {
    
    private func fetchGroups() {
        self.groupManager.fetchGroups { [weak self] result in
            switch result {
            case .success(let existingNote):
                self?.groups = existingNote
                self?.filteredgroups = self?.groups ?? existingNote
                self?.fetchUsers()
            case .failure(let error):
                print("fetchData.failure: \(error)")
            }
        }
    }
    
    private func fetchUsers() {
        
        self.userManager.fetchUsers { [weak self] result in
            switch result {
            case .success(let existingUser):
                self?.users = existingUser
                for user in existingUser where user.uid == self?.currentUserId {
                    self?.user = user
                }
                
                // Filter Blocked Users
                guard let blockedUids = self?.user?.blockUsers else { return }
                for blockedUid in blockedUids {
                    self?.users = self?.users.filter { $0.uid != blockedUid} ?? []
                }
                
                // Filter Blocked Users Content
                for blockedUid in blockedUids {
                    self?.filteredgroups = self?.filteredgroups.filter { $0.groupOwner != blockedUid} ?? []
                    self?.groups = self?.groups.filter { $0.groupOwner != blockedUid} ?? []
                }
                
                DispatchQueue.main.async {
                    LKProgressHUD.dismiss()
                    self?.searchGroupsTableView.reloadData()
                }
            case .failure(let error):
                print("fetchData.failure: \(error)")
            }
        }
    }
    
}

// MARK: Search result tableview datasource
extension SearchGroupsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredgroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let groupResultTableViewCell = tableView.dequeueReusableCell(withIdentifier: "GroupResultTableViewCell", for: indexPath)
        guard let cell = groupResultTableViewCell as? GroupResultTableViewCell else { return groupResultTableViewCell }
        cell.titleLabel.text = filteredgroups[indexPath.row].groupTitle
        let mainImageUrl = URL(string: filteredgroups[indexPath.row].groupCover)
        cell.mainImageView.kf.indicatorType = .activity
        cell.mainImageView.kf.setImage(with: mainImageUrl)
        let date = filteredgroups[indexPath.row].createdTime
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        cell.dateLabel.text = formatter.string(from: date)
        cell.membersLabel.text = "\(filteredgroups[indexPath.row].groupMembers.count)"
        cell.categoryLabel.setTitle(filteredgroups[indexPath.row].groupCategory, for: .normal)
        
        // querying users' name & avatar
        for user in users where user.uid == filteredgroups[indexPath.row].groupOwner {
            cell.aurthorNameLabel.text = user.userName
            let avatarUrl = URL(string: user.userAvatar)
            cell.avatarImageView.kf.indicatorType = .activity
            cell.avatarImageView.kf.setImage(with: avatarUrl)
        }
        return cell
    }
    
}

// MARK: Search result tableview delegate
extension SearchGroupsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "GroupDetail", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "GroupDetailViewController") as? GroupDetailViewController else { return }
        viewController.group = filteredgroups[indexPath.row]
        viewController.users = users
        viewController.user = user
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
