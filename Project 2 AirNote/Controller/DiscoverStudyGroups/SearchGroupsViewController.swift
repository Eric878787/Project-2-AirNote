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
    private var users: [User] = []
    
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
        fetchGroups()
        
        // Fetch users
        fetchUsers()
        
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
        
        searchGroupsTableView.registerCellWithNib(identifier: String(describing: GroupResultTableViewCell.self), bundle: nil)
        searchGroupsTableView.automaticallyAdjustsScrollIndicatorInsets = false
        searchGroupsTableView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        searchGroupsTableView.dataSource = self
        searchGroupsTableView.delegate = self
        
        view.addSubview(searchGroupsTableView)
        
        searchGroupsTableView.translatesAutoresizingMaskIntoConstraints = false
        searchGroupsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        searchGroupsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        searchGroupsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        searchGroupsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
    }
    
}

// MARK: Fetch Data
extension SearchGroupsViewController {
    
    private func fetchGroups() {
        self.groupManager.fetchGroups { [weak self] result in
            
            switch result {
                
            case .success(let existingNote):
                
                DispatchQueue.main.async {
                    self?.groups = existingNote
                    self?.filteredgroups = self?.groups ?? existingNote
                    self?.searchGroupsTableView.reloadData()
                }
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
    }
    
    private func fetchUsers() {
        
        self.userManager.fetchUsers { [weak self] result in
            
            switch result {
                
            case .success(let existingUser):
                
                DispatchQueue.main.async {
                    self?.users = existingUser
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
        
        // querying users' name & avatar
        for user in users where user.userId == filteredgroups[indexPath.row].groupOwner {
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height * 0.5
    }
    
}
