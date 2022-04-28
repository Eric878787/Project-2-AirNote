//
//  ProfileViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/24.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var profilePageTableView: UITableView!
    
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    var users: [User] = []
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Log out Button
        let deleteButton = UIBarButtonItem(image: UIImage(systemName: "arrowshape.turn.up.forward.fill"), style: .plain, target: self, action: #selector(signOut))
        self.navigationItem.rightBarButtonItem = deleteButton
        
        profilePageTableView.dataSource = self
        profilePageTableView.registerCellWithNib(identifier: String(describing: PersonalNoteTableViewCell.self), bundle: nil)
        
        // Configure Delete Account
        deleteAccountButton.setTitle("刪除帳號", for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUsers()
    }
    
    
    @IBAction func deleteAccount(_ sender: Any) {
        
        FirebaseManager.shared.delete()
        FirebaseManager.shared.deleteAccountSuccess = {
            guard let uid = FirebaseManager.shared.currentUser?.uid else { return }
            UserManager.shared.deleteUser(uid: uid) { result in
                switch result {
                case .success:
                    let controller = UIAlertController(title: "刪除帳號成功", message: "請重新註冊", preferredStyle: .alert)
                    controller.view.tintColor = UIColor.gray
                    let action = UIAlertAction(title: "確認", style: .destructive) { _ in
                        
                        if self.presentingViewController == nil {
                            
                            guard let vc = UIStoryboard.auth.instantiateInitialViewController() else { return }
                            
                            vc.modalPresentationStyle = .fullScreen
                            
                            self.present(vc, animated: true)
                            
                        } else {
                            
                            self.dismiss(animated: true)
                            
                        }
                    }
                    
                    controller.addAction(action)
                    self.present(controller, animated: true)
                    
                case .failure:
                    let controller = UIAlertController(title: "刪除帳號失敗", message: "請重新註冊", preferredStyle: .alert)
                    controller.view.tintColor = UIColor.gray
                    let action = UIAlertAction(title: "確認", style: .destructive)
                    controller.addAction(action)
                    self.present(controller, animated: true)
                }
            }
        }
        
    }
    
}

extension ProfileViewController {
    
    @objc func signOut() {
        
        FirebaseManager.shared.signout()
        
        if self.presentingViewController == nil {
            
            guard let vc = UIStoryboard.auth.instantiateInitialViewController() else { return }
            
            vc.modalPresentationStyle = .fullScreen
            
            self.present(vc, animated: true)
            
        } else {
            
            self.dismiss(animated: true)
            
        }
        
    }
    
    private func fetchUsers() {
        
        UserManager.shared.fetchUsers { result in
            switch result {
                
            case .success(let existingUser):
                
                self.users = existingUser
                
                for user in self.users where user.userId == "qbQsVVpVHlf6I4XLfOJ6" {
                    self.user = user
                }
                
                DispatchQueue.main.async {
                    
                    self.profilePageTableView.reloadData()
                    
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
        
        let personalNoteTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PersonalNoteTableViewCell", for: indexPath)
        guard let cell = personalNoteTableViewCell as? PersonalNoteTableViewCell else { return personalNoteTableViewCell }
        cell.savedNoteLabel.text = user?.savedNotes[indexPath.row]
        return cell
    }
    
    
}
