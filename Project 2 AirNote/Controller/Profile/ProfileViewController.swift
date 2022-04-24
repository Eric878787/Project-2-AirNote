//
//  ProfileViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/24.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var savedNoteTableView: UITableView!
    
    var userManager = UserManager()
    
    var users: [User] = []
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        savedNoteTableView.dataSource = self
        savedNoteTableView.registerCellWithNib(identifier: String(describing: SavedNoteTableViewCell.self), bundle: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUsers()
    }
    
    private func fetchUsers() {
        
        userManager.fetchUsers { result in
            switch result {
                
            case .success(let existingUser):
                
                self.users = existingUser
                
                for user in self.users where user.userId == "qbQsVVpVHlf6I4XLfOJ6" {
                    self.user = user
                }
                
                DispatchQueue.main.async {
                    
                    self.savedNoteTableView.reloadData()
                    
                }
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        user?.savedNotes.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let savedNoteTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SavedNoteTableViewCell", for: indexPath)
        guard let cell = savedNoteTableViewCell as? SavedNoteTableViewCell else { return savedNoteTableViewCell }
        cell.savedNoteLabel.text = user?.savedNotes[indexPath.row]
        return cell
    }
    

}
