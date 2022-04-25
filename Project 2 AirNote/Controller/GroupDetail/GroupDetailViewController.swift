//
//  GroupDetailViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/23.
//

import UIKit
import Kingfisher

class GroupDetailViewController: UIViewController {
    
    @IBOutlet weak var groupDetailCollectionView: UICollectionView!
    
    @IBOutlet weak var chatRoomButton: UIButton!
    
    // Data
    var group: Group?
    var users: [User] = []
    
    // Data Manager
    private var groupManager = GroupManager()
    private var userManager = UserManager()
    private var chatRoomManager = ChatRoomManager()
    
    // MARK: Loading Animation
    private var loadingAnimation = LottieAnimation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register Cell
        registerCell()
        
        // CollectionView DataSource
        groupDetailCollectionView.dataSource = self
        
        // CollectionView Layout
        groupDetailCollectionView.collectionViewLayout = configureLayout()
        
        // Config Button
        configButton()
        
        // Delete Button
        let deleteButton = UIBarButtonItem(image: UIImage(systemName: "clear"), style: .plain, target: self, action: #selector(deleteGroup))
        self.navigationItem.rightBarButtonItem = deleteButton
        
    }
}

// MARK: Delete Note
extension GroupDetailViewController {
    @objc private func deleteGroup() {
        let controller = UIAlertController(title: "刪除成功", message: "", preferredStyle: .alert)
        controller.view.tintColor = UIColor.gray
        guard let groupToBeDeleted = group?.groupId else { return }
        groupManager.deleteGroup(groupId: groupToBeDeleted) { result in
            switch result {
            case .success:
                let cancelAction = UIAlertAction(title: "確認", style: .destructive) { _ in
                    self.navigationController?.popToRootViewController(animated: true)
                }
                // fetch chat room id
                self.chatRoomManager.fetchRooms { result in
                    switch result {
                    case .success(let rooms):
                        for room in rooms where room.groupId == groupToBeDeleted {
                            // delete chat room
                            self.chatRoomManager.deleteChatRoom(chatRoomId: room.chatRoomId) { result in
                                switch result {
                                case .success:
                                    DispatchQueue.main.async {
                                        self.loadingAnimation.loadingView.pause()
                                        self.loadingAnimation.loadingView.isHidden = true
                                        controller.addAction(cancelAction)
                                        self.present(controller, animated: true, completion: nil)
                                    }
                                case.failure:
                                    print(result)
                                }
                            }
                        }
                    case .failure(let error):
                        print("fetchData.failure: \(error)")
                    }
                }
            case.failure:
                print(result)
            }
        }
    }
}

// MARK: Configure Button
extension GroupDetailViewController {
    func configButton() {
        chatRoomButton.setTitle("聊天室", for: .normal)
    }
}

// MARK: CollectionView Register Cell
extension GroupDetailViewController {
    func registerCell() {
        groupDetailCollectionView.register(GroupCoverCollectionViewCell.self, forCellWithReuseIdentifier: GroupCoverCollectionViewCell.reuseIdentifer)
        groupDetailCollectionView.registerCellWithNib(identifier: String(describing: GroupTitleCollectionViewCell.self), bundle: nil)
        groupDetailCollectionView.registerCellWithNib(identifier: String(describing: GroupCalendarCollectionViewCell.self), bundle: nil)
        groupDetailCollectionView.register(GroupContentCollectionViewCell.self, forCellWithReuseIdentifier: GroupContentCollectionViewCell.reuseIdentifer)
        groupDetailCollectionView.register(TitleSupplementaryView.self,
                                           forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                           withReuseIdentifier: TitleSupplementaryView.reuseIdentifier)
    }
}

// MARK: CollectionView DataSource
extension GroupDetailViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return group?.schedules.count ?? 0
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let group = group else { return UICollectionViewCell()}
        
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupCoverCollectionViewCell.reuseIdentifer, for: indexPath)
                    as? GroupCoverCollectionViewCell else { return UICollectionViewCell()}
            let url = URL(string: group.groupCover)
            cell.photoView.kf.indicatorType = .activity
            cell.photoView.kf.setImage(with: url)
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: GroupTitleCollectionViewCell.self), for: indexPath)
                    as? GroupTitleCollectionViewCell else { return UICollectionViewCell()}
            cell.locationLabel.text = group.location.address
            let localDate = group.createdTime
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd"
            cell.dateLabel.text = dateFormatter.string(from: localDate)
            return cell
        case 2:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupCalendarCollectionViewCell.reuseIdentifer, for: indexPath)
                    as? GroupCalendarCollectionViewCell else { return UICollectionViewCell()}
            let localDate = group.schedules[indexPath.item].date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd"
            cell.dateLabel.text = dateFormatter.string(from: localDate)
            cell.contentLabel.text = group.schedules[indexPath.item].title
            let date = Date()
            if localDate < date {
                cell.durationLabel.text = "過期"
            } else {
                cell.durationLabel.text = "進行中"
            }
            return cell
        case 3:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: GroupContentCollectionViewCell.self), for: indexPath)
                    as? GroupContentCollectionViewCell else { return UICollectionViewCell()}
            cell.contentLabel.text = group.groupContent
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let group = group else { return UICollectionReusableView()}
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleSupplementaryView.reuseIdentifier, for: indexPath)
                as? TitleSupplementaryView else { return UICollectionReusableView() }
        
        switch indexPath.section {
        case 0:
            header.textLabel.text = ""
            return header
        case 1:
            header.textLabel.text = group.groupTitle
            return header
        case 2:
            header.textLabel.text = "排程"
            return header
        case 3:
            header.textLabel.text = "內容"
            return header
        default:
            return UICollectionReusableView()
        }
    }
}

// MARK: CollectionView Compositional Layout
extension GroupDetailViewController {
    
    func configureLayout() -> UICollectionViewCompositionalLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            switch sectionIndex {
            case 0:
                return self.configLargeSection()
            case 1 :
                return self.configMidiumSection()
            case 2:
                return self.configCalendarSection()
            case 3:
                return self.configMidiumSection()
                
            default:
                return self.configLargeSection()
            }
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    func configLargeSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        section.interGroupSpacing = 10
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    func configMidiumSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    func configCalendarSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
}
