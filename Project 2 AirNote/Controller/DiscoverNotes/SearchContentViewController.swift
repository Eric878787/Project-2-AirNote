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
        
        searchNotesTableView.registerCellWithNib(identifier: String(describing: NoteResultTableViewCell.self), bundle: nil)
        searchNotesTableView.dataSource = self
        searchNotesTableView.delegate = self
        
        view.addSubview(searchNotesTableView)
        
        searchNotesTableView.translatesAutoresizingMaskIntoConstraints = false
        searchNotesTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10 ).isActive = true
        searchNotesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        searchNotesTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        searchNotesTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        
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
                DispatchQueue.main.async {
                    self?.searchNotesTableView.reloadData()
                }
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
    }
}

// MARK: Search result tableview datasource
extension SearchContentViewController: UITableViewDataSource, NoteResultDelegate {
    
    func saveNote(_ selectedCell: NoteResultTableViewCell) {
        
        var selectedIndexPathItem = searchNotesTableView.indexPath(for: selectedCell)?.row
        
        guard let item = selectedIndexPathItem else { return }
        
        var selectedNote = Note(authorId: notes[item].noteId,
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
            
            selectedNote.likes.append("qbQsVVpVHlf6I4XLfOJ6")
            
        } else {
            
            selectedNote.likes = selectedNote.likes.filter{ $0 != "qbQsVVpVHlf6I4XLfOJ6" }
            
        }
        
        noteManager.updateNote(note: selectedNote, noteId: selectedNote.noteId) { result in
            
            switch result {
                
            case .success:
                
                self.fetchNotes()
                
                var userToBeUpdated: User?
                
                for user in self.users where user.userId == "qbQsVVpVHlf6I4XLfOJ6"{
                    
                    userToBeUpdated = user
                    
                }
                
                if selectedCell.likeButton.imageView?.image == UIImage(systemName: "suit.heart") {
                    
                    userToBeUpdated?.savedNotes.append(selectedNote.noteId)
                    
                } else {
                    
                    let user = userToBeUpdated
                    
                    userToBeUpdated?.savedNotes =  user?.savedNotes.filter{ $0 != "\(selectedNote.noteId)" } ?? []
                    
                }
                
                guard let userToBeUpdated = userToBeUpdated else {
                    return
                }
                
                self.userManager.updateUser(user: userToBeUpdated, userId: userToBeUpdated.userId) { result in
                    
                    switch result {
                        
                    case .success:
                        
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
        
        // Highlight saved note
        cell.likeButton.setImage(UIImage(systemName: "suit.heart"), for: .normal)
        for like in filteredNotes[indexPath.row].likes {
            if like == "qbQsVVpVHlf6I4XLfOJ6" {
                cell.likeButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
            }
        }
        
        // querying users' name & avatar
        for user in users where user.userId == filteredNotes[indexPath.row].authorId {
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height * 0.5
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "NotesDetail", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "NoteDetailViewController") as? NoteDetailViewController else { return }
        filteredNotes[indexPath.row].clicks.append("qbQsVVpVHlf6I4XLfOJ6")
        noteManager.updateNote(note: filteredNotes[indexPath.row], noteId: filteredNotes[indexPath.row].noteId) { [weak self] result in
            switch result {
            case .success:
                vc.note = self?.filteredNotes[indexPath.row]
                vc.users = self?.users ?? []
                self?.navigationController?.pushViewController(vc, animated: true)
                
            case .failure(let error):
                print("fetchData.failure: \(error)")
            }
        }

    }
    
}
