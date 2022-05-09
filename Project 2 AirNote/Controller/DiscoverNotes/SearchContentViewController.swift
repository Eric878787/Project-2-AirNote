//
//  SearchNotesViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/16.
//

import UIKit

class SearchContentViewController: UIViewController {
    
    // Search result tableview
    private var searchNotesTableView = UITableView(frame: .zero)
    
    // Search Controller
    private var searchController = UISearchController()
    
    // Search Result datasource
    private var noteManager = NoteManager()
    private var userManager = UserManager()
    private var notes: [Note] = []
    private lazy var filteredNotes: [Note] = []
    private var users: [User] = []
    private var currentUser: User?
    private var userToBeBlocked = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure search result tableview
        configureSearchNoteTableview()
        
        // Configure search controller
        self.navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fetch notes
        fetchNotes()
        searchNotesTableView.reloadData()
        
    }
}
    

// MARK: Protocol UISearchResultsUpdating
extension SearchContentViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, searchText.isEmpty == false  {
            filteredNotes = notes.filter({ note in
                let keyWord = note.keywords.joined()
                let isInKeyWords = keyWord.localizedStandardContains(searchText)
                
                let category = note.category
                let isInCategory = category.localizedStandardContains(searchText)
                
                let isInTitle = note.title.localizedStandardContains(searchText)
                
                if isInKeyWords || isInCategory || isInTitle == true {
                    return true
                } else {
                    return false
                }
            })
            
        } else {
            filteredNotes = notes
        }
        searchNotesTableView.reloadData()
    }
    
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

// MARK: Configure search result tableview
extension SearchContentViewController {
    
    private func configureSearchNoteTableview() {
        
        self.searchNotesTableView.separatorColor = .clear
        
        searchNotesTableView.registerCellWithNib(identifier: String(describing: NoteResultTableViewCell.self), bundle: nil)
        searchNotesTableView.dataSource = self
        searchNotesTableView.delegate = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        searchNotesTableView.addGestureRecognizer(longPress)
        
        view.addSubview(searchNotesTableView)
        
        searchNotesTableView.translatesAutoresizingMaskIntoConstraints = false
        searchNotesTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        searchNotesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        searchNotesTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        searchNotesTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
    }
    
}

// MARK: Fetch Data
extension SearchContentViewController {
    
    private func fetchNotes() {
        self.noteManager.fetchNotes { [weak self] result in
            
            switch result {
                
            case .success(let existingNote):
    
                    self?.notes = existingNote
                    self?.filteredNotes = self?.notes ?? existingNote
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
                
                for user in existingUser where user.uid == FirebaseManager.shared.currentUser?.uid {
                    
                    self?.currentUser = user
                    
                }
                
                // Filter Blocked Users
                guard let blockedUids = self?.currentUser?.blockUsers else { return }
                
                for blockedUid in blockedUids {
                    
                    self?.users = self?.users.filter{$0.uid != blockedUid} ?? []
                    
                }
                
                // Filter Blocked Users Content
                
                for blockedUid in blockedUids {
                    
                    self?.filteredNotes = self?.filteredNotes.filter{$0.authorId != blockedUid} ?? []
                    
                    self?.notes = self?.notes.filter{$0.authorId != blockedUid} ?? []
                    
                }
                
                DispatchQueue.main.async {
                    self?.searchNotesTableView.reloadData()
                }
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
    }
}

// MARK: Block User
extension SearchContentViewController {
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: searchNotesTableView)
            if let indexPath = searchNotesTableView.indexPathForRow(at: touchPoint) {
                userToBeBlocked = filteredNotes[indexPath.row].authorId
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

// MARK: Search result tableview datasource
extension SearchContentViewController: UITableViewDataSource, NoteResultDelegate {
    
    func saveNote(_ selectedCell: NoteResultTableViewCell) {
        
        guard let currentUser = FirebaseManager.shared.currentUser else {
            
            guard let vc = UIStoryboard.auth.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
            
            vc.modalPresentationStyle = .overCurrentContext

            self.tabBarController?.present(vc, animated: false, completion: nil)
            
            return
            
        }
        
        var selectedIndexPathItem = searchNotesTableView.indexPath(for: selectedCell)?.row
        
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
        
        if selectedCell.likeButton.imageView?.image == UIImage(systemName: "suit.heart") {
            
            selectedNote.likes.append(currentUser.uid)
            
        } else {
            
            selectedNote.likes = selectedNote.likes.filter{ $0 != currentUser.uid }
            
        }
        
        noteManager.updateNote(note: selectedNote, noteId: selectedNote.noteId) { result in
            
            switch result {
                
            case .success:
                
                self.fetchNotes()
                
                var userToBeUpdated = self.currentUser
                
                if selectedCell.likeButton.imageView?.image == UIImage(systemName: "suit.heart") {
                    
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
                        
                        self.searchNotesTableView.reloadData()
                        
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredNotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let noteResultTableViewCell = tableView.dequeueReusableCell(withIdentifier: "NoteResultTableViewCell", for: indexPath)
        guard let cell = noteResultTableViewCell as? NoteResultTableViewCell else { return noteResultTableViewCell }
        cell.delegate = self
        cell.titleLabel.text = filteredNotes[indexPath.row].title
        let mainImageUrl = URL(string: filteredNotes[indexPath.row].cover)
        cell.mainImageView.kf.indicatorType = .activity
        cell.mainImageView.kf.setImage(with: mainImageUrl)
        cell.categoryButton.setTitle("\(filteredNotes[indexPath.row].category)", for: .normal)
        
        // Highlight saved note
        cell.likeButton.setImage(UIImage(systemName: "suit.heart"), for: .normal)
        for like in filteredNotes[indexPath.row].likes {
            if like == FirebaseManager.shared.currentUser?.uid {
                cell.likeButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
            }
        }
        
        // querying users' name & avatar
        for user in users where user.uid == filteredNotes[indexPath.row].authorId {
            cell.aurthorNameLabel.text = user.userName
            let avatarUrl = URL(string: user.userAvatar)
            cell.avatarImageView.kf.indicatorType = .activity
            cell.avatarImageView.kf.setImage(with: avatarUrl)
        }
        
        return cell
    }
    
}

// MARK: Search result tableview delegate
extension SearchContentViewController: UITableViewDelegate {
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let currentUser = FirebaseManager.shared.currentUser else {
            
            guard let vc = UIStoryboard.auth.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
            
            vc.modalPresentationStyle = .overCurrentContext

            self.tabBarController?.present(vc, animated: false, completion: nil)
            
            return
            
        }
        
        guard let currentUser = FirebaseManager.shared.currentUser else {
            
            guard let vc = UIStoryboard.auth.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
            
            vc.modalPresentationStyle = .overCurrentContext

            self.tabBarController?.present(vc, animated: false, completion: nil)
            
            return
            
        }
        
        let storyboard = UIStoryboard(name: "NotesDetail", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "NoteDetailViewController") as? NoteDetailViewController else { return }
        filteredNotes[indexPath.row].clicks.append(currentUser.uid)
        noteManager.updateNote(note: filteredNotes[indexPath.row], noteId: filteredNotes[indexPath.row].noteId) { [weak self] result in
            switch result {
            case .success:
                guard let noteToPass = self?.filteredNotes[indexPath.row] else { return }
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
