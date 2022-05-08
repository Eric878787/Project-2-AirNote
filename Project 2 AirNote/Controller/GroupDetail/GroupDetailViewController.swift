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
    var owner: User?
    var room: ChatRoom?
    var users: [User] = []
    var user: User?
    
    // Data Manager
    private var groupManager = GroupManager()
    private var userManager = UserManager()
    private var chatRoomManager = ChatRoomManager()
    
    // DeleteButton
    private var deleteButton = UIBarButtonItem()
    
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
        deleteButton = UIBarButtonItem(image: UIImage(systemName: "clear"), style: .plain, target: self, action: #selector(deleteGroup))
        self.navigationItem.rightBarButtonItem = deleteButton
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //  Delete Button Enable
        if group?.groupOwner == user?.uid {
            self.navigationItem.rightBarButtonItem = deleteButton
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        // Mapping Group Owner
        for user in users where user.uid == group?.groupOwner {
            owner = user
        }
        
    }
    
}

// MARK: Delete Group
extension GroupDetailViewController {
    @objc private func deleteGroup() {
        
        var controller = UIAlertController(title: "是否要刪除讀書會", message: "刪除後即無法回復內容", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "確認", style: .default) { _ in
            guard let groupToBeDeleted = self.group?.groupId else { return }
            self.groupManager.deleteGroup(groupId: groupToBeDeleted) { result in
                switch result {
                case .success:
                    self.updateUser(groupId: groupToBeDeleted)
                case.failure:
                    print(result)
                }
            }
        }
        confirmAction.setValue(UIColor.red, forKey: "titleTextColor")
        controller.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        
        self.present(controller, animated: true, completion: nil)
    }
    
    func updateUser(groupId: String) {
        let controller = UIAlertController(title: "刪除成功", message: "", preferredStyle: .alert)
        controller.view.tintColor = UIColor.gray
        var uids : [String] = []
        for user in users {
            uids.append(user.uid)
        }
        UserManager.shared.deleteGroup(uids: uids, groupId: groupId) { [weak self] result in
            switch result {
            case .success:
                guard let userToBeUpdated = self?.user else { return }
                UserManager.shared.deleteOwnGroup(uid: userToBeUpdated.uid, groupId: groupId) { [weak self] result in
                    switch result {
                    case .success:
                        let cancelAction = UIAlertAction(title: "確認", style: .destructive) { _ in
                            self?.navigationController?.popViewController(animated: true)
                        }
                        DispatchQueue.main.async {
                            cancelAction.setValue(UIColor.black, forKey: "titleTextColor")
                            controller.addAction(cancelAction)
                            self?.present(controller, animated: true, completion: nil)
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: Join Group
extension GroupDetailViewController: GroupTitleDelegate {
    
    func joinOrQuit(_ selectedCell: GroupTitleCollectionViewCell) {
        
        if isMember() == true {
            quitGroup()
        } else {
            joinGroup()
        }
        
    }
    
    // update group & user
    private func joinGroup() {
        let controller = UIAlertController(title: "加入成功", message: "", preferredStyle: .alert)
        controller.view.tintColor = UIColor.gray
        
        self.user?.joinedGroups.append(self.group?.groupId ?? "")
        
        guard let userToBeUpdated = self.user else { return }
        
        userManager.updateUser(user: userToBeUpdated, uid: userToBeUpdated.uid) { [weak self] result in
            switch result {
            case .success:
                self?.group?.groupMembers.append(self?.user?.uid ?? "")
                self?.updateGroup(controller)
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    // update group & user
    private func quitGroup() {
        let controller = UIAlertController(title: "退出成功", message: "", preferredStyle: .alert)
        controller.view.tintColor = UIColor.gray
        
        guard let joinedGroups = self.user?.joinedGroups else { return }
        self.user?.joinedGroups = joinedGroups.filter { $0 != self.group?.groupId } ?? []
        
        guard let userToBeUpdated = self.user else { return }
        
        userManager.updateUser(user: userToBeUpdated, uid: userToBeUpdated.uid) { [weak self] result in
            switch result {
            case .success:
                guard let groupMembers = self?.group?.groupMembers else { return }
                self?.group?.groupMembers = groupMembers.filter { $0 != self?.user?.uid } ?? []
                self?.updateGroup(controller)
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    private func updateGroup(_ controller: UIAlertController) {
        
        guard let groupToBeUpdated = self.group else { return }
        GroupManager.shared.updateGroup(group: groupToBeUpdated, groupId: groupToBeUpdated.groupId) { [weak self] result in
            switch result {
            case .success:
                let cancelAction = UIAlertAction(title: "確認", style: .destructive) { _ in
                    self?.navigationController?.popViewController(animated: true)
                }
                DispatchQueue.main.async {
                    cancelAction.setValue(UIColor.black, forKey: "titleTextColor")
                    controller.addAction(cancelAction)
                    self?.present(controller, animated: true, completion: nil)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func isMember() -> Bool {
        guard let groupMembers = group?.groupMembers else { return false }
        for memberId in groupMembers where memberId == self.user?.uid {
            return true
        }
        return false
    }
    
}

// MARK: Configure Button
extension GroupDetailViewController {
    func configButton() {
        chatRoomButton.setTitle("聊天室", for: .normal)
        chatRoomButton.titleLabel?.font = UIFont(name: "PingFangTC-Semibold", size: 14)
        chatRoomButton.clipsToBounds = true
        chatRoomButton.layer.cornerRadius = 10
        chatRoomButton.addTarget(self, action: #selector(toChatRoom), for: .touchUpInside)
        
        if isMember() == true {
            chatRoomButton.isEnabled = true
            chatRoomButton.setTitleColor(.white, for: .normal)
            chatRoomButton.backgroundColor = .myDarkGreen
        } else {
            chatRoomButton.isEnabled = false
            chatRoomButton.setTitleColor(.systemGray2, for: .disabled)
            chatRoomButton.backgroundColor = .white
            chatRoomButton.layer.borderColor = UIColor.systemGray2.cgColor
            chatRoomButton.layer.borderWidth = 1
        }
        
    }
    
   @objc func toChatRoom() {
        let storyBoard = UIStoryboard(name: "ChatroomLobby", bundle: nil)
        guard let vc =  storyBoard.instantiateViewController(withIdentifier: "ChatRoomViewController") as? ChatRoomViewController else { return }
        vc.group = self.group
        self.navigationController?.pushViewController(vc, animated: true)
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
            return 1
        case 3:
            return group?.schedules.count ?? 0
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
            cell.delegate = self
            cell.locationLabel.text = group.location.address
            let localDate = group.createdTime
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd"
            cell.dateLabel.text = dateFormatter.string(from: localDate)
            cell.memberLabel.text = "\(group.groupMembers.count)"
            
            // Define the user is owner or not
            if user?.uid == group.groupOwner {
                cell.applyButton.setTitle("我的讀書會", for: .normal)
                cell.applyButton.isEnabled = false
                cell.applyButton.setTitleColor( .myDarkGreen, for: .disabled)
                cell.applyButton.backgroundColor = .white
                cell.applyButton.layer.borderWidth = 1
                cell.applyButton.layer.borderColor = UIColor.myDarkGreen.cgColor
            } else {
                if isMember() == true {
                    cell.applyButton.setTitle("退出", for: .normal)
                    cell.applyButton.isEnabled = true
                    cell.applyButton.setTitleColor(.myDarkGreen, for: .normal)
                    cell.applyButton.backgroundColor = .white
                    cell.applyButton.layer.borderWidth = 1
                    cell.applyButton.layer.borderColor = UIColor.myDarkGreen.cgColor
                } else {
                    cell.applyButton.setTitle("加入", for: .normal)
                    cell.applyButton.isEnabled = true
                    cell.applyButton.setTitleColor(.white, for: .normal)
                    cell.applyButton.backgroundColor = .myDarkGreen
                }
            }
            
            return cell
        case 2:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupContentCollectionViewCell.reuseIdentifer, for: indexPath)
                    as?  GroupContentCollectionViewCell else { return UICollectionViewCell()}
            cell.contentLabel.text = group.groupContent
            return cell
        case 3:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: GroupCalendarCollectionViewCell.self), for: indexPath)
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
            header.avatar.isHidden = false
            header.name.isHidden = false
            header.textLabel.isHidden = true
            header.timeLabel.isHidden = true
            if owner?.userAvatar != nil {
                let url = URL(string: owner?.userAvatar ?? "")
                header.avatar.kf.indicatorType = .activity
                header.avatar.kf.setImage(with: url)
            } else {
                header.avatar.image = UIImage(systemName: "person.circle.fill")
                header.avatar.tintColor = .myDarkGreen
            }
            header.name.text = owner?.userName
            
            return header
        case 1:
            header.textLabel.text = group.groupTitle
            let localDate = group.createdTime
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY/MM/dd"
            header.timeLabel.text = dateFormatter.string(from: localDate)
            header.textLabel.isHidden = false
            header.avatar.isHidden = true
            header.name.isHidden = true
            header.timeLabel.isHidden = false
            return header
        case 2:
            header.textLabel.isHidden = true
            header.avatar.isHidden = true
            header.name.isHidden = true
            header.timeLabel.isHidden = true
            return header
        case 3:
            header.textLabel.text = "排程"
            header.textLabel.isHidden = false
            header.avatar.isHidden = true
            header.name.isHidden = true
            header.timeLabel.isHidden = true
            return header
        default:
            return UICollectionReusableView()
        }
    }
}

// MARK: CollectionView Compositional Layout
extension GroupDetailViewController {
    
    private func configureLayout() -> UICollectionViewCompositionalLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            switch sectionIndex {
            case 0:
                return self.configSection0()
            case 1:
                return self.configSection1()
            case 2:
                return self.configSection2()
            case 3:
                return self.configSection3()
                
            default:
                return self.configSection0()
            }
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    private func configSection0() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let groupHeight = NSCollectionLayoutDimension.fractionalWidth(0.8)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: groupHeight)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        sectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    private func configSection1() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 5, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(80))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        sectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    private func configSection2() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 5, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
        
        return section
    }
    
    private func configSection3() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(45))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        sectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
}
