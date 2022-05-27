//
//  Discover Notes View Controller.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/9.
//

import UIKit
import Kingfisher
import FirebaseAuth

class DiscoverStudyGroupsViewController: BaseViewController {
    
    // MARK: Properties
    private var categoryCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        var categoryCollecitonView = UICollectionView(
            frame: CGRect.zero,
            collectionViewLayout: layout
        )
        categoryCollecitonView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        categoryCollecitonView.registerCellWithNib(identifier: String(describing: CategoryCollectionViewCell.self), bundle: nil)
        categoryCollecitonView.backgroundColor = .clear
        return categoryCollecitonView
    }()
    
    private var groupsCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        var groupsCollectionView = UICollectionView(
            frame: CGRect.zero,
            collectionViewLayout: layout
        )
        groupsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        groupsCollectionView.registerCellWithNib(identifier: String(describing: GroupsCollectionViewCell.self), bundle: nil)
        groupsCollectionView.backgroundColor = .clear
        return groupsCollectionView
    }()
    
    // Add Group Button
    private var addGroupButton = UIButton()
    
    // Category
    private var selectedCategoryIndex = 0
    var categories: [GeneralCategory] = [.all, .finance, .sport, .language, .communication, .marketing, .lifestyle, .entertainment]
    
    // Data Provider
    private var groupManager = GroupManager()
    var userManager = UserManager()
    
    // Groups Data
    private var groups: [Group] = []
    private var filterGroups: [Group] = []
    
    // Users Data
    var users: [User] = []
    var user: User?
    private var userToBeBlocked = ""
    var currentUser = Auth.auth().currentUser
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NavigationItemTitle.discoverGroups.rawValue
        configureCategoryCollectionView()
        configureGroupsCollectionView()
        configureAddGroupButton()
        let searchButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"),
                                           style: .plain,
                                           target: self,
                                           action: #selector(toSearchPage))
        self.navigationItem.rightBarButtonItem = searchButton
        let mapButton = UIBarButtonItem(image: UIImage(systemName: "map"),
                                        style: .plain,
                                        target: self,
                                        action: #selector(toMapPage))
        self.navigationItem.leftBarButtonItem =  mapButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedCategoryIndex = 0
        categoryCollectionView.reloadData()
        LKProgressHUD.show()
        fetchGroups()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addGroupButton.layer.cornerRadius = addGroupButton.frame.height / 2
    }
    
}

// MARK: Configure Add Note Button
extension DiscoverStudyGroupsViewController {
    
    func configureAddGroupButton() {
        addGroupButton.translatesAutoresizingMaskIntoConstraints = false
        addGroupButton.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        addGroupButton.backgroundColor = .myDarkGreen
        addGroupButton.tintColor = .white
        addGroupButton.imageView?.contentMode = .scaleAspectFill
        addGroupButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        addGroupButton.addTarget(self, action: #selector(pushToNextPage), for: .touchUpInside)
        view.addSubview(addGroupButton)
        NSLayoutConstraint.activate([
            addGroupButton.widthAnchor.constraint(equalToConstant: 50),
            addGroupButton.heightAnchor.constraint(equalTo: addGroupButton.widthAnchor),
            addGroupButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            addGroupButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30)
        ])
    }
    
    @objc func pushToNextPage() {
        guard self.currentUser != nil else {
            guard let viewController = UIStoryboard.auth.instantiateViewController(withIdentifier: "AuthViewController")
                    as? AuthViewController else { return }
            
            viewController.modalPresentationStyle = .overCurrentContext
            self.tabBarController?.present(viewController, animated: false, completion: nil)
            return
        }
        
        guard let viewController = UIStoryboard.addContent.instantiateViewController(withIdentifier: "AddGroupViewController")
                as? AddGroupViewController else { return }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}


// MARK: To Map Page
extension DiscoverStudyGroupsViewController {
    
    @objc private func toMapPage() {
        guard self.currentUser != nil else {
            guard let viewController = UIStoryboard.auth.instantiateViewController(withIdentifier: "AuthViewController")
                    as? AuthViewController else { return }
            viewController.modalPresentationStyle = .overCurrentContext
            self.tabBarController?.present(viewController, animated: false, completion: nil)
            return
            
        }
        let storyBoard = UIStoryboard(name: "DiscoverStudyGroups", bundle: nil)
        guard let viewController =  storyBoard.instantiateViewController(withIdentifier: "GroupMapViewController") as? GroupMapViewController else { return }
        viewController.groups = self.groups
        viewController.user = self.user
        viewController.users = self.users
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

// MARK: To Search Page
extension DiscoverStudyGroupsViewController {
    
    @objc private func toSearchPage() {
        guard self.currentUser != nil else {
            guard let viewController = UIStoryboard.auth.instantiateViewController(withIdentifier: "AuthViewController")
                    as? AuthViewController else { return }
            viewController.modalPresentationStyle = .overCurrentContext
            self.tabBarController?.present(viewController, animated: false, completion: nil)
            return
        }
        let storyBoard = UIStoryboard(name: "SearchContent", bundle: nil)
        guard let viewController =  storyBoard.instantiateViewController(withIdentifier: "SearchGroupsViewController")
                as? SearchGroupsViewController else { return }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: Block User
extension DiscoverStudyGroupsViewController {
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        guard self.currentUser != nil else {
            guard let viewController = UIStoryboard.auth.instantiateViewController(withIdentifier: "AuthViewController")
                    as? AuthViewController else { return }
            
            viewController.modalPresentationStyle = .overCurrentContext
            self.tabBarController?.present(viewController, animated: false, completion: nil)
            return
        }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        if sender.state == .began {
            let touchPoint = sender.location(in: groupsCollectionView)
            if let indexPath = groupsCollectionView.indexPathForItem(at: touchPoint) {
                userToBeBlocked = filterGroups[indexPath.item].groupOwner
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
        guard userToBeBlocked != currentUser?.uid else {
            let controller = UIAlertController(title: "無法封鎖本人帳號", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "確認", style: .default)
            controller.addAction(action)
            self.present(controller, animated: true)
            return
        }
        guard let followers = self.user?.followers else { return }
        guard let followings = self.user?.followings else { return }
        self.user?.followers = followers.filter{ $0 != userToBeBlocked }
        self.user?.followings = followings.filter{ $0 != userToBeBlocked }
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

// MARK: Configure Category CollectionView
extension DiscoverStudyGroupsViewController {
    
    private func configureCategoryCollectionView() {
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        view.addSubview(categoryCollectionView)
        categoryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        categoryCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
        categoryCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        categoryCollectionView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/8).isActive = true
        categoryCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
    }
    
}

// MARK: Fetch Data
extension DiscoverStudyGroupsViewController {
    
    private func fetchGroups() {
        self.groupManager.fetchGroups { [weak self] result in
            switch result {
            case .success( let existingGroup ):
                self?.groups = existingGroup
                self?.filterGroups = self?.groups ?? existingGroup
                self?.fetchUsers()
            case .failure( let error ):
                print("fetchData.failure: \(error)")
            }
        }
    }
    
    private func fetchUsers() {
        self.userManager.fetchUsers { [weak self] result in
            switch result {
            case .success(let existingUser):
                self?.users = existingUser
                guard let users = self?.users else { return }
                for user in users where user.uid == self?.currentUser?.uid {
                    self?.user = user
                }
                
                // Filter Blocked Users
                if let blockedUids = self?.user?.blockUsers {
                    for blockedUid in blockedUids {
                        self?.users = self?.users.filter{ $0.uid != blockedUid} ?? []
                    }
                    
                    // Filter Blocked Users Content
                    for blockedUid in blockedUids {
                        self?.filterGroups = self?.filterGroups.filter{ $0.groupOwner != blockedUid} ?? []
                        self?.groups = self?.groups.filter{ $0.groupOwner != blockedUid} ?? []
                    }
                }
                
                DispatchQueue.main.async {
                    LKProgressHUD.dismiss()
                    self?.groupsCollectionView.reloadData()
                }
            case .failure(let error):
                print("fetchData.failure: \(error)")
            }
        }
    }
    
}


// MARK: Configure Groups CollecitonView
extension DiscoverStudyGroupsViewController {
    
    private func configureGroupsCollectionView() {
        groupsCollectionView.dataSource = self
        groupsCollectionView.delegate = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        groupsCollectionView.addGestureRecognizer(longPress)
        view.addSubview(groupsCollectionView)
        groupsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        groupsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
        groupsCollectionView.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor).isActive = true
        groupsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        groupsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
    }
    
}

// MARK: CollectionView DataSource
extension DiscoverStudyGroupsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView {
            return categories.count
        } else {
            return filterGroups.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
            let categoryCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath)
            guard let cell = categoryCollectionViewCell
                    as? CategoryCollectionViewCell else { return categoryCollectionViewCell }
            cell.categoryLabel.text = categories[indexPath.item].rawValue
            if selectedCategoryIndex == indexPath.item {
                cell.categoryLabel.textColor = .white
                cell.categoryView.backgroundColor = .myDarkGreen
            } else {
                cell.categoryLabel.textColor = .myDarkGreen
                cell.categoryView.backgroundColor = .white
            }
            cell.isMultipleTouchEnabled = false
            return cell
        } else {
            let groupsCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupsCollectionViewCell", for: indexPath)
            guard let cell = groupsCollectionViewCell
                    as? GroupsCollectionViewCell else { return groupsCollectionViewCell }
            let url = URL(string: filterGroups[indexPath.item].groupCover)
            cell.coverImage.kf.indicatorType = .activity
            cell.coverImage.kf.setImage(with: url)
            cell.titleLabel.text = filterGroups[indexPath.item].groupTitle
            let localDate = filterGroups[indexPath.item].createdTime
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd"
            cell.dateLabel.text = dateFormatter.string(from: localDate)
            cell.memberCountsLabel.text = "\(filterGroups[indexPath.item].groupMembers.count)"
            
            // querying users' name & avatar
            for user in users where user.uid == filterGroups[indexPath.item].groupOwner {
                cell.authorNameLabel.text = user.userName
                let url = URL(string: user.userAvatar)
                cell.userAvatar.kf.indicatorType = .activity
                cell.userAvatar.kf.setImage(with: url)
            }
            return cell
        }
    }
    
}

// MARK: CollectionView Delegate
extension DiscoverStudyGroupsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell else {return}
            selectedCategoryIndex = indexPath.item
            collectionView.reloadData()
            if cell.categoryLabel.text != GeneralCategory.all.rawValue {
                filterGroups = groups.filter { $0.groupCategory == cell.categoryLabel.text }
            } else {
                filterGroups = groups
            }
            groupsCollectionView.reloadData()
        } else {
            guard self.currentUser != nil else {
                guard let viewController = UIStoryboard.auth.instantiateViewController(withIdentifier: "AuthViewController")
                        as? AuthViewController else { return }
                viewController.modalPresentationStyle = .overCurrentContext
                self.tabBarController?.present(viewController, animated: false, completion: nil)
                return
            }
            let storyboard = UIStoryboard(name: "GroupDetail", bundle: nil)
            guard let viewController = storyboard.instantiateViewController(withIdentifier: "GroupDetailViewController") as? GroupDetailViewController else { return }
            viewController.group = filterGroups[indexPath.item]
            viewController.users = users
            viewController.user = user
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
}

// MARK: CollectionView FlowLayout
extension DiscoverStudyGroupsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == categoryCollectionView {
            let maxWidth = UIScreen.main.bounds.width - 40
            let numberOfItemsPerRow = CGFloat(4.2)
            let interItemSpacing = CGFloat(10)
            let itemWidth = (maxWidth - interItemSpacing) / numberOfItemsPerRow
            let itemHeight = itemWidth * 0.4
            return CGSize(width: itemWidth, height: itemHeight)
        } else {
            let maxWidth = UIScreen.main.bounds.width - 10
            let numberOfItemsPerRow = CGFloat(2)
            let interItemSpacing = CGFloat(10)
            let itemWidth = (maxWidth - interItemSpacing) / numberOfItemsPerRow
            let itemHeight = itemWidth * 1.4
            return CGSize(width: itemWidth, height: itemHeight)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 10
        }
}
