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
        
        // Fetch users
        fetchUsers()
        
    }
    
}

// MARK: Protocol UISearchResultsUpdating
extension SearchContentViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, searchText.isEmpty == false  {
            filteredNotes = notes.filter({ note in
                let keyWord = note.noteKeywords.joined()
                let isInKeyWords = keyWord.localizedStandardContains(searchText)
                
                let category = note.noteCategory
                let isInCategory = category.localizedStandardContains(searchText)
                
                let isInTitle = note.noteTitle.localizedStandardContains(searchText)
                
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
        searchNotesTableView.automaticallyAdjustsScrollIndicatorInsets = false
        searchNotesTableView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        searchNotesTableView.dataSource = self
        searchNotesTableView.delegate = self
        
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
                
                DispatchQueue.main.async {
                    self?.notes = existingNote
                    self?.filteredNotes = self?.notes ?? existingNote
                    self?.searchNotesTableView.reloadData()
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
                    self?.searchNotesTableView.reloadData()
                }
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
    }
}

// MARK: Search result tableview datasource
extension SearchContentViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredNotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let noteResultTableViewCell = tableView.dequeueReusableCell(withIdentifier: "NoteResultTableViewCell", for: indexPath)
        guard let cell = noteResultTableViewCell as? NoteResultTableViewCell else { return noteResultTableViewCell }
        cell.titleLabel.text = filteredNotes[indexPath.row].noteTitle
        let mainImageUrl = URL(string: filteredNotes[indexPath.row].noteCover)
        cell.mainImageView.kf.indicatorType = .activity
        cell.mainImageView.kf.setImage(with: mainImageUrl)
        
        // querying users' name & avatar
        for user in users where user.userId == filteredNotes[indexPath.row].authorId {
            cell.authorNameLabel.text = user.userName
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
    
}
