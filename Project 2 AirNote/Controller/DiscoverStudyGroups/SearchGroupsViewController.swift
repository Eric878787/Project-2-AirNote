//
//  SearchGroupsViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/19.
//

import UIKit

class SearchGroupsViewController: UIViewController {
    
    // Search result tableview
    private var searchGroupsTableView = UITableView(frame: .zero)
    
    // Search Controller
    private var searchController = UISearchController()
    
    // Search Result datasource
    private var groupManager = GroupManager()
    private var userManager = UserManager()
    private var groups: [Group] = []
    private lazy var filteredgroups: [Group] = []
    var users: [User] = []
    var user: User?
    var currentUserId = FirebaseManager.shared.currentUser?.uid
    private var userToBeBlocked = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure search result tableview
        configureSearchGroupsTableView()
        
        // Configure search controller
        self.navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fetch notes
        LKProgressHUD.show()
        fetchGroups()
        
    }
    
}

// MARK: Protocol UISearchResultsUpdating
extension SearchGroupsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, searchText.isEmpty == false  {
            filteredgroups = groups.filter({ group in
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
            })

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
extension SearchGroupsViewController  {
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: searchGroupsTableView)
            if let indexPath = searchGroupsTableView.indexPathForRow(at: touchPoint) {
                userToBeBlocked = filteredgroups[indexPath.row].groupOwner
                openActionList()
            }
        }
    }
    
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
    
    private func blockUser() {
        
        user?.blockUsers.append(userToBeBlocked)
        
        guard let currentUser = user else { return }
        
        UserManager.shared.updateUser(user: currentUser, uid: currentUser.uid) { result in
            
            switch result {
                
            case .success:
                let controller = UIAlertController(title: "封鎖成功", message: nil, preferredStyle: .alert)
                let action = UIAlertAction(title: "確認", style: .default) { action in
                    self.fetchGroups()
                }
                controller.addAction(action)
                self.present(controller, animated: true)
                
                print("封鎖成功")
                
            case .failure:
                
                print("封鎖失敗")
                
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
                
                // Fetch users
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
                    
                    self?.users = self?.users.filter{ $0.uid != blockedUid} ?? []
                    
                }
                
                // Filter Blocked Users Content
                
                for blockedUid in blockedUids {
                    
                    self?.filteredgroups = self?.filteredgroups.filter{ $0.groupOwner != blockedUid} ?? []
                    
                    self?.groups = self?.groups.filter{ $0.groupOwner != blockedUid} ?? []
                    
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
        guard let vc = storyboard.instantiateViewController(withIdentifier: "GroupDetailViewController") as? GroupDetailViewController else { return }
        vc.group = filteredgroups[indexPath.row]
        vc.users = users
        vc.user = user
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
