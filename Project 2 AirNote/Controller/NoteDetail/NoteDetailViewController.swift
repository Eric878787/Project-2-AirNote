//
//  NoteDetailViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/21.
//

import UIKit
import Kingfisher

class NoteDetailViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var noteDetailCollectionView: UICollectionView!
    
    @IBOutlet weak var commentTextFiled: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    // Data
    var note = Note(authorId: "",
                    comments: [],
                    createdTime: Date(),
                    likes: [],
                    category: "",
                    clicks: [],
                    content: "",
                    cover: "",
                    noteId: "",
                    images: [],
                    keywords: [],
                    title: "")
    
    var users: [User] = []
    
    var currentUser: User?
    
    var aurthor: User?
    
    var editButton = UIBarButtonItem()
    
    var comments: [Comment] = []
    
    var userToBeBlocked = ""
    
    // Data Manager
    private var noteManager = NoteManager()
    private var userManager = UserManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register Cell
        registerCell()
        
        // CollectionView DataSource & Delegate
        noteDetailCollectionView.dataSource = self
        noteDetailCollectionView.delegate = self
        
        // Textfield Delegate
        commentTextFiled.delegate = self
        
        // Send Button Color
        sendButton.tintColor = .myDarkGreen
        
        // CollectionView Layout
        noteDetailCollectionView.collectionViewLayout = configureLayout()
        
        // Edit Button
        editButton  = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: self, action: #selector(toEditPage))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //  Edit Button Enable
        if note.authorId == currentUser?.uid {
            self.navigationItem.rightBarButtonItem = editButton
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        // Filter Author
        for user in users where user.uid == note.authorId {
            aurthor = user
        }
        
        // Filter Blocked User's Note
        filterBlockedUsersComment()
        
    }
    
    @IBAction func sendComment(_ sender: Any) {
        
        guard let content = commentTextFiled.text else {
            sendButton.isEnabled = false
            return
        }
        
        if content.count <= 15 && content.count >= 1 {
            
            let newComment = Comment(content: content, createdTime: Date(), uid: FirebaseManager.shared.currentUser?.uid ?? "")
            note.comments.append(newComment)
            comments.append(newComment)
            note.comments.sort{
                ( $0.createdTime ) < ( $1.createdTime )
            }
            comments.sort {
                ( $0.createdTime ) < ( $1.createdTime )
            }
            
            noteManager.updateNote(note: self.note, noteId: self.note.noteId) { [weak self] result in
                switch result {
                case .success:
                    
                    let controller = UIAlertController(title: "評論成功", message: nil, preferredStyle: .alert)
                    controller.view.tintColor = UIColor.gray
                    let action = UIAlertAction(title: "確認", style: .destructive)
                    action.setValue(UIColor.black, forKey: "titleTextColor")
                    controller.addAction(action)
                    self?.present(controller, animated: true)
                    
                    DispatchQueue.main.async {
                        
                        self?.commentTextFiled.text = ""
                        
                        self?.noteDetailCollectionView.reloadData()
                        if self?.note.comments != [] {
                            self?.noteDetailCollectionView.scrollToItem(at: [3, (self?.note.comments.count ?? 1) - 1], at: .bottom, animated: true)
                        }
                    }
                case .failure(let error):
                    print("fetchData.failure: \(error)")
                }
            }
        } else {
            let controller = UIAlertController(title: "評論失敗", message: "評論字數應介於1-15", preferredStyle: .alert)
            controller.view.tintColor = UIColor.gray
            let action = UIAlertAction(title: "確認", style: .destructive)
            action.setValue(UIColor.black, forKey: "titleTextColor")
            controller.addAction(action)
            self.present(controller, animated: true)
        }
    }
}

// MARK: Block User
extension NoteDetailViewController {
    
    private func filterBlockedUsersComment() {
        
        // Filter Blocked Users
        if let blockedUids = self.currentUser?.blockUsers {
            
            // Filter Blocked Users Content
            
            for blockedUid in blockedUids {
                
                self.comments = self.comments.filter{ $0.uid != blockedUid}
                
                
            }
        }
        
        noteDetailCollectionView.reloadData()
        
    }
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        
        if (sender.state == UIGestureRecognizer.State.ended) {
            
            let touchPoint = sender.location(in: noteDetailCollectionView)
            
            if let indexPath = self.noteDetailCollectionView.indexPathForItem(at: touchPoint) {
                
                userToBeBlocked = comments[indexPath.item].uid
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
        
        currentUser?.blockUsers.append(userToBeBlocked)
        
        guard let currentUser = currentUser else { return }
        
        UserManager.shared.updateUser(user: currentUser, uid: currentUser.uid) { result in
            
            switch result {
                
            case .success:
                let controller = UIAlertController(title: "封鎖成功", message: nil, preferredStyle: .alert)
                let action = UIAlertAction(title: "確認", style: .default) { action in
                    self.fetchUser()
                }
                controller.addAction(action)
                self.present(controller, animated: true)
                
                print("封鎖成功")
                
            case .failure:
                
                print("封鎖失敗")
                
            }
        }
        
    }
    
    func fetchUser() {
        
        UserManager.shared.fetchUser(currentUser?.uid ?? "") { [weak self] result in
            
            switch result {
            case .success (let user):
                
                self?.currentUser = user
                
                self?.filterBlockedUsersComment()
                
            case .failure (let error):
                
                print(error)
            }
            
        }
    }
    
}

// MARK: Textfield Delegate
extension NoteDetailViewController {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 15
    }
    
}

// MARK: To edit page
extension NoteDetailViewController {
    @objc private func toEditPage() {
        let storyBoard = UIStoryboard(name: "AddContent", bundle: nil)
        guard let vc = storyBoard.instantiateViewController(withIdentifier: "EditNoteViewController") as? EditNoteViewController else { return }
        vc.note = self.note
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: CollectionView Register Cell
extension NoteDetailViewController {
    private func registerCell() {
        noteDetailCollectionView.register(NoteCarouselCollectionViewCell.self, forCellWithReuseIdentifier: NoteCarouselCollectionViewCell.reuseIdentifer)
        noteDetailCollectionView.registerCellWithNib(identifier: String(describing: NoteTitleCollectionViewCell.self), bundle: nil)
        noteDetailCollectionView.register(NoteContentCollectionViewCell.self, forCellWithReuseIdentifier: NoteContentCollectionViewCell.reuseIdentifer)
        noteDetailCollectionView.registerCellWithNib(identifier: String(describing: NoteCommentCollectionViewCell.self), bundle: nil)
        noteDetailCollectionView.register(TitleSupplementaryView.self,
                                          forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                          withReuseIdentifier: TitleSupplementaryView.reuseIdentifier)
    }
}

// MARK: To Profile Page
extension NoteDetailViewController {
    
    func toProfilePage() {
        
        if aurthor?.uid != currentUser?.uid {
            let storyBoard = UIStoryboard(name: "Profile", bundle: nil)
            guard let vc =  storyBoard.instantiateViewController(withIdentifier: "OtherProfileViewController") as? OtherProfileViewController else { return }
            vc.userInThisPage = self.aurthor
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.tabBarController?.selectedIndex = 4
        }
    }
    
}

// MARK: Save Note
extension NoteDetailViewController: NoteTitleDelegate {
    
    func saveNote(_ selectedCell: NoteTitleCollectionViewCell) {
        
        guard let currentUser = FirebaseManager.shared.currentUser else {
            
            guard let vc = UIStoryboard.auth.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
            
            vc.modalPresentationStyle = .overCurrentContext
            
            self.tabBarController?.present(vc, animated: false, completion: nil)
            
            return
            
        }
        
        if selectedCell.saveButton.imageView?.image == UIImage(systemName: "suit.heart") {
            
            self.note.likes.append(currentUser.uid)
            
        } else {
            
            self.note.likes = self.note.likes.filter{ $0 != currentUser.uid }
            
        }
        
        NoteManager.shared.updateNote(note: note, noteId: note.noteId) { result in
            
            switch result {
                
            case .success:
                
                self.fetchNote()
                
                var userToBeUpdated: User?
                
                for user in self.users where user.uid == FirebaseManager.shared.currentUser?.uid{
                    
                    userToBeUpdated = user
                    
                }
                
                if selectedCell.saveButton.imageView?.image == UIImage(systemName: "suit.heart") {
                    
                    let user = userToBeUpdated
                    
                    userToBeUpdated?.savedNotes =  user?.savedNotes.filter{ $0 != "\(self.note.noteId)" } ?? []
                    
                    userToBeUpdated?.savedNotes.append(self.note.noteId)
                    
                } else {
                    
                    let user = userToBeUpdated
                    
                    userToBeUpdated?.savedNotes =  user?.savedNotes.filter{ $0 != "\(self.note.noteId)" } ?? []
                    
                }
                
                guard let userToBeUpdated = userToBeUpdated else {
                    return
                }
                
                self.userManager.updateUser(user: userToBeUpdated, uid: userToBeUpdated.uid) { result in
                    
                    switch result {
                        
                    case .success:
                        
                        self.noteDetailCollectionView.reloadData()
                        
                        print("收藏成功")
                        
                    case .failure:
                        
                        print("收藏失敗")
                        
                    }
                }
                
            case .failure:
                
                print("收藏失敗")
            }
            
        }
        
    }
    
    func fetchNote() {
        
        NoteManager.shared.fetchNote(self.note.noteId) { result in
            
            switch result {
                
            case .success(let note):
                
                self.note = note
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
            
        }
        
    }
    
}


// MARK: CollectionView DataSource
extension NoteDetailViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return note.images.count ?? 0
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return comments.count ?? 0
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteCarouselCollectionViewCell.reuseIdentifer, for: indexPath)
                    as? NoteCarouselCollectionViewCell else { return UICollectionViewCell()}
            let url = URL(string: note.images[indexPath.item])
            cell.photoView.kf.indicatorType = .activity
            cell.photoView.kf.setImage(with: url)
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: NoteTitleCollectionViewCell.self), for: indexPath)
                    as? NoteTitleCollectionViewCell else { return UICollectionViewCell()}
            cell.delegate = self
            cell.viewsLabel.text = "\(note.clicks.count)"
            cell.commentCountsLabel.text = "\(note.comments.count)"
            
            // Highlight saved note
            cell.saveButton.setImage(UIImage(systemName: "suit.heart"), for: .normal)
            for like in note.likes {
                if like == FirebaseManager.shared.currentUser?.uid {
                    cell.saveButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
                }
            }
            
            return cell
        case 2:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteContentCollectionViewCell.reuseIdentifer, for: indexPath)
                    as? NoteContentCollectionViewCell else { return UICollectionViewCell()}
            cell.contentLabel.text = note.content
            return cell
        case 3:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: NoteCommentCollectionViewCell.self), for: indexPath)
                    as? NoteCommentCollectionViewCell else { return UICollectionViewCell()}
            cell.commentLabel.text = comments[indexPath.item].content
            let date = comments[indexPath.item].createdTime
            let locoalDate = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd"
            cell.commentTimeLabel.text = date.timeAgoDisplay()
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
            cell.addGestureRecognizer(longPress)
            
            // querying users' name & avatar
            for user in users where user.uid == comments[indexPath.item].uid {
                cell.nameLabel.text = user.userName
                let url = URL(string: user.userAvatar)
                cell.avatarImageView.kf.indicatorType = .activity
                cell.avatarImageView.kf.setImage(with: url)
            }
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleSupplementaryView.reuseIdentifier, for: indexPath)
                as? TitleSupplementaryView else { return UICollectionReusableView() }
        header.delegate = self
        
        switch indexPath.section {
        case 0:
            header.avatar.isHidden = false
            header.name.isHidden = false
            header.textLabel.isHidden = true
            header.timeLabel.isHidden = true
            if aurthor?.userAvatar != nil {
                let url = URL(string: aurthor?.userAvatar ?? "")
                header.avatar.kf.indicatorType = .activity
                header.avatar.kf.setImage(with: url)
            } else {
                header.avatar.image = UIImage(systemName: "person.circle.fill")
                header.avatar.tintColor = .myDarkGreen
            }
            header.name.text = aurthor?.userName
            
            return header
        case 1:
            header.textLabel.text = note.title
            let localDate = note.createdTime
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
            header.textLabel.text = "評論"
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

// MARK: CollectionView Delegate
extension NoteDetailViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            let vc = ImageViewerViewController()
            vc.images = self.note.images
            vc.currentPage = indexPath.item
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

// MARK: CollectionView Compositional Layout
extension NoteDetailViewController {
    
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
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(30))
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

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
