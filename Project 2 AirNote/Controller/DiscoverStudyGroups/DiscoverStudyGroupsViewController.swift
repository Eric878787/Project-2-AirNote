//
//  Discover Notes View Controller.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/9.
//

import UIKit
import Kingfisher

class DiscoverStudyGroupsViewController: UIViewController {
    
    // MARK: CollecitonView Properties
    var categoryCollectionView: UICollectionView = {
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
    
    // MARK: Category
    private var selectedCategoryIndex = 0
    var category: [String] = ["所有讀書會", "投資理財", "運動健身", "語言學習", "人際溝通", "廣告行銷", "生活風格", "藝文娛樂"]
    
    // MARK: Data Provider
    private var groupManager = GroupManager()
    var userManager = UserManager()
    
    // MARK: Groups Data
    private var groups: [Group] = []
    private var filterGroups: [Group] = []
    
    // MARK: Users Data
    var users: [User] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Up Navigation Item
        navigationItem.title = "探索讀書會"
        
        // Set Up Category CollectionView
        configureCategoryCollectionView()
        
        // Set Up Groups CollectionView
        configureGroupsCollectionView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fetch Groups Data
        fetchGroups()
        
        // Fetch Users Data
        fetchUsers()
    }
    
}


// MARK: Configure Category CollectionView
extension DiscoverStudyGroupsViewController {
    
    private func configureCategoryCollectionView() {
        
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        
        view.addSubview(categoryCollectionView)
        
        categoryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        categoryCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        categoryCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        categoryCollectionView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/10).isActive = true
        categoryCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}

// MARK: Fetch Data
extension DiscoverStudyGroupsViewController {
    
    private func fetchGroups() {
        self.groupManager.fetchGroups { [weak self] result in
            
            switch result {
                
            case .success(let existingGroup):
                
                DispatchQueue.main.async {
                    self?.groups = existingGroup
                    self?.filterGroups = self?.groups ?? existingGroup
                    self?.groupsCollectionView.reloadData()
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
        
        view.addSubview(groupsCollectionView)
        
        groupsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        groupsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        groupsCollectionView.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor).isActive = true
        groupsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        groupsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
}

// MARK: CollectionView DataSource
extension DiscoverStudyGroupsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView {
            return category.count
        } else {
            return filterGroups.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
            let categoryCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath)
            guard let cell = categoryCollectionViewCell as? CategoryCollectionViewCell else {return categoryCollectionViewCell}
            cell.categoryLabel.text = category[indexPath.item]
            if selectedCategoryIndex == indexPath.item {
                cell.categoryLabel.textColor = .black
            } else {
                cell.categoryLabel.textColor = .systemGray2
            }
            cell.isMultipleTouchEnabled = false
            return cell
        } else {
            let groupsCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupsCollectionViewCell", for: indexPath)
            guard let cell = groupsCollectionViewCell as? GroupsCollectionViewCell else {return groupsCollectionViewCell}
            let url = URL(string: filterGroups[indexPath.item].groupCover)
            cell.coverImage.kf.indicatorType = .activity
            cell.coverImage.kf.setImage(with: url)
            cell.titleLabel.text = filterGroups[indexPath.item].groupTitle
            let localDate = filterGroups[indexPath.item].createdTime.toLocalTime()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd"
            cell.dateLabel.text = dateFormatter.string(from: localDate)
            cell.memberCountsLabel.text = "\(filterGroups[indexPath.item].groupMembers.count)"
            
            // querying users' name & avatar
            for user in users where user.userId == filterGroups[indexPath.item].groupOwner {
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
            
            if cell.categoryLabel.text != "所有讀書會" {
                filterGroups = groups.filter { $0.groupCategory == cell.categoryLabel.text }
            } else {
                filterGroups = groups
            }
            groupsCollectionView.reloadData()
            
        } else {
            let groupsCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupsCollectionViewCell", for: indexPath)
            guard let cell = groupsCollectionViewCell as? GroupsCollectionViewCell else {return}
        }
    }
}


// MARK: CollectionView FlowLayout
extension DiscoverStudyGroupsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == categoryCollectionView {
            return CGSize(width: 100, height: 30)
        } else {
            let maxWidth = UIScreen.main.bounds.width
            let numberOfItemsPerRow = CGFloat(2)
            let interItemSpacing = CGFloat(0)
            let itemWidth = (maxWidth - interItemSpacing) / numberOfItemsPerRow
            let itemHeight = itemWidth * 1.8
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
            if collectionView == categoryCollectionView {
                return 0
            } else {
                return 0
            }
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == categoryCollectionView {
            return 0
        } else {
            return 0
        }
    }
}


