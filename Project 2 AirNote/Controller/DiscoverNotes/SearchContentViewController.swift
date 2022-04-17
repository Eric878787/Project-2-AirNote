//
//  SearchNotesViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/16.
//

import UIKit

class SearchContentViewController: UIViewController {
    
     // Search result tableview
    var searchNotesTableView = UITableView(frame: .zero)
    
    // Search Result datasource
    var noteManager = NoteManager()
    var userManager = UserManager()
    var notes: [Note] = []
    var users: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure search result tableview
        configureSearchNoteTableview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fetch notes
        fetchNotes()
        
        // Fetch users
        fetchUsers()
        
    }
    
}

// MARK: Configure search result tableview
extension SearchContentViewController {
    
    private func configureSearchNoteTableview() {
        
        searchNotesTableView.registerCellWithNib(identifier: String(describing: NoteResultTableViewCell.self) , bundle: nil)
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
        notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let noteResultTableViewCell = tableView.dequeueReusableCell(withIdentifier: "NoteResultTableViewCell", for: indexPath)
        guard let cell = noteResultTableViewCell as? NoteResultTableViewCell else { return noteResultTableViewCell }
        return cell
    }
    
}

// MARK: Search result tableview delegate
extension SearchContentViewController: UITableViewDelegate {
    
    
    
}
