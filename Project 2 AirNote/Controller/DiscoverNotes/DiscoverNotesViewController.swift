//
//  Discover Notes View Controller.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/9.
//

import UIKit
import Kingfisher

class DiscoverNotesViewController: UIViewController {
    
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
        categoryCollecitonView.showsVerticalScrollIndicator = false
        categoryCollecitonView.showsHorizontalScrollIndicator = false
        return categoryCollecitonView
    }()
    
    private var notesCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        var notesCollectionView = UICollectionView(
            frame: CGRect.zero,
            collectionViewLayout: layout
        )
        notesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        notesCollectionView.registerCellWithNib(identifier: String(describing: NotesCollectionViewCell.self), bundle: nil)
        notesCollectionView.backgroundColor = .clear
        return notesCollectionView
    }()
    
    // MARK: Category
    private var selectedCategoryIndex = 0
    var category: [String] = ["所有筆記", "投資理財", "運動健身", "語言學習", "人際溝通", "廣告行銷", "生活風格", "藝文娛樂"]
    
    // MARK: Data Provider
    private var noteManager = NoteManager()
    var userManager = UserManager()
    var userToBeBlocked = ""
    
    // MARK: Notes Data
    private var notes: [Note] = []
    private var filterNotes: [Note] = []
    
    // MARK: Users Data
    var users: [User] = []
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Up Navigation Item
        navigationItem.title = "探索筆記"
        
        // Set Up Category CollectionView
        configureCategoryCollectionView()
        
        // Set Up Notes CollecitonView
        configureNotesCollectionView()
        
        // Search Button
        let searchButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(toSearchPage))
        self.navigationItem.rightBarButtonItem = searchButton
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Default selection
        selectedCategoryIndex = 0
        categoryCollectionView.reloadData()
        
        // Fetch Notes Data
        fetchNotes()
        
    }
}

// MARK: Fetch Data
extension DiscoverNotesViewController {
    
    private func fetchNotes() {
        self.noteManager.fetchNotes { [weak self] result in
            
            switch result {
                
            case .success(let existingNote):
                
                self?.notes = existingNote
                self?.filterNotes = self?.notes ?? existingNote
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
                
                // Store Current User
                self?.storeCurrentUser()
                
                // Filter Blocked Users
                if let blockedUids = self?.currentUser?.blockUsers {
                    
                    for blockedUid in blockedUids {
                        
                        self?.users = self?.users.filter{ $0.uid != blockedUid} ?? []
                        
                    }
                    
                    // Filter Blocked Users Content
                    
                    for blockedUid in blockedUids {
                        
                        self?.filterNotes = self?.filterNotes.filter{ $0.authorId != blockedUid} ?? []
                        
                        self?.notes = self?.notes.filter{ $0.authorId != blockedUid} ?? []
                        
                    }
                }
                
                
                DispatchQueue.main.async {
                    self?.notesCollectionView.reloadData()
                }
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
    }
    
    private func storeCurrentUser() {
        
        for user in users where user.uid == FirebaseManager.shared.currentUser?.uid {
            
            currentUser = user
            
        }
        
    }
    
}

// MARK: To Next Page
extension DiscoverNotesViewController {
    
    @objc private func toSearchPage() {
        
        guard let currentUser = self.currentUser else {
            
            guard let vc = UIStoryboard.auth.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
            
            vc.modalPresentationStyle = .overCurrentContext
            
            self.tabBarController?.present(vc, animated: false, completion: nil)
            
            return
            
        }
        
        let storyBoard = UIStoryboard(name: "SearchContent", bundle: nil)
        guard let vc =  storyBoard.instantiateViewController(withIdentifier: "SearchContentViewController") as? SearchContentViewController else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: Block User
extension DiscoverNotesViewController {
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: notesCollectionView)
            if let indexPath = notesCollectionView.indexPathForItem(at: touchPoint) {
                userToBeBlocked = filterNotes[indexPath.item].authorId
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
                let action = UIAlertAction(title: "返回首頁", style: .default) { action in
                    self.navigationController?.popToRootViewController(animated: true)
                    self.fetchNotes()
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

// MARK: Configure Category CollectionView
extension DiscoverNotesViewController {
    
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

// MARK: Configure Notes CollecitonView
extension DiscoverNotesViewController {
    
    private func configureNotesCollectionView() {
        notesCollectionView.dataSource = self
        notesCollectionView.delegate = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        notesCollectionView.addGestureRecognizer(longPress)
        
        view.addSubview(notesCollectionView)
        
        notesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        notesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
        notesCollectionView.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor).isActive = true
        notesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        notesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
    }
    
}

// MARK: CollectionView DataSource
extension DiscoverNotesViewController: UICollectionViewDataSource, NoteCollectionDelegate {
    
    func saveNote(_ selectedCell: NotesCollectionViewCell) {
        
        guard let currentUser = self.currentUser else {
            
            guard let vc = UIStoryboard.auth.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
            
            vc.modalPresentationStyle = .overCurrentContext
            
            self.tabBarController?.present(vc, animated: false, completion: nil)
            
            return
            
        }
        
        var selectedIndexPathItem = notesCollectionView.indexPath(for: selectedCell)?.item
        
        guard let item = selectedIndexPathItem else { return }
        
        var selectedNote = Note(authorId: notes[item].authorId,
                                comments: notes[item].comments,
                                createdTime: notes[item].createdTime,
                                likes: notes[item].likes,
                                category: notes[item].category,
                                clicks: notes[item].clicks,
                                content: notes[item].content,
                                cover: notes[item].cover,
                                noteId: notes[item].noteId,
                                images:notes[item].images,
                                keywords:notes[item].keywords,
                                title: notes[item].title)
        
        if selectedCell.heartButton.imageView?.image == UIImage(systemName: "suit.heart") {
            
            selectedNote.likes.append(currentUser.uid)
            
            
        } else {
            
            selectedNote.likes = selectedNote.likes.filter{ $0 != currentUser.uid }
            
        }
        
        noteManager.updateNote(note: selectedNote, noteId: selectedNote.noteId) { result in
            
            switch result {
                
            case .success:
                
                self.fetchNotes()
                
                var userToBeUpdated = self.currentUser
                
                if selectedCell.heartButton.imageView?.image == UIImage(systemName: "suit.heart") {
                    
                    userToBeUpdated?.savedNotes.append(selectedNote.noteId)
                    
                } else {
                    
                    let user = userToBeUpdated
                    
                    userToBeUpdated?.savedNotes =  user?.savedNotes.filter{ $0 != "\(selectedNote.noteId)" } ?? []
                    
                }
                
                guard let userToBeUpdated = userToBeUpdated else {
                    return
                }
                
                self.userManager.updateUser(user: userToBeUpdated, uid: userToBeUpdated.uid) { result in
                    
                    switch result {
                        
                    case .success:
                        
                        self.notesCollectionView.reloadData()
                        
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView {
            return category.count
        } else {
            return filterNotes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
            let categoryCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath)
            guard let cell = categoryCollectionViewCell as? CategoryCollectionViewCell else {return categoryCollectionViewCell}
            cell.categoryLabel.text = category[indexPath.item]
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
            let notesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotesCollectionViewCell", for: indexPath)
            guard let cell = notesCollectionViewCell as? NotesCollectionViewCell else {return notesCollectionViewCell}
            let url = URL(string: filterNotes[indexPath.item].cover)
            cell.delegate = self
            cell.coverImage.kf.indicatorType = .activity
            cell.coverImage.kf.setImage(with: url)
            cell.titleLabel.text = filterNotes[indexPath.item].title
            
            // Highlight saved note
            cell.heartButton.setImage(UIImage(systemName: "suit.heart"), for: .normal)
            
            for like in filterNotes[indexPath.item].likes {
                if like == FirebaseManager.shared.currentUser?.uid {
                    cell.heartButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
                }
            }
            
            // querying users' name & avatar
            for user in users where user.uid == filterNotes[indexPath.item].authorId {
                cell.authorNameLabel.text = user.userName
                let url = URL(string: user.userAvatar)
                cell.userAvatarImage.kf.indicatorType = .activity
                cell.userAvatarImage.kf.setImage(with: url)
            }
            return cell
        }
    }
}

// MARK: CollectionView Delegate
extension DiscoverNotesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == categoryCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell else {return}
            selectedCategoryIndex = indexPath.item
            collectionView.reloadData()
            
            if cell.categoryLabel.text != "所有筆記" {
                filterNotes = notes.filter { $0.category == cell.categoryLabel.text }
            } else {
                filterNotes = notes
            }
            notesCollectionView.reloadData()
            
        } else {
            
            guard let currentUser = self.currentUser else {
                
                guard let vc = UIStoryboard.auth.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
                
                vc.modalPresentationStyle = .overCurrentContext
                
                self.tabBarController?.present(vc, animated: false, completion: nil)
                
                return
                
            }
            
            let storyboard = UIStoryboard(name: "NotesDetail", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "NoteDetailViewController") as? NoteDetailViewController else { return }
            guard let uid = FirebaseManager.shared.currentUser?.uid else { return }
            filterNotes[indexPath.item].clicks.append(uid)
            noteManager.updateNote(note: filterNotes[indexPath.item], noteId: filterNotes[indexPath.item].noteId) { [weak self] result in
                switch result {
                case .success:
                    guard let noteToPass = self?.filterNotes[indexPath.item] else { return }
                    vc.note = noteToPass
                    vc.comments = noteToPass.comments
                    vc.users = self?.users ?? []
                    vc.currentUser = self?.currentUser
                    self?.navigationController?.pushViewController(vc, animated: true)
                    
                case .failure(let error):
                    print("fetchData.failure: \(error)")
                }
            }
        }
    }
}


// MARK: CollectionView FlowLayout
extension DiscoverNotesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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
            let itemHeight = itemWidth * 1.2
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
                return 10
            } else {
                return 10
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
