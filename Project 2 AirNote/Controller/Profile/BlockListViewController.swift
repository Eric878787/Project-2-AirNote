//
//  BlockListViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/5/4.
//

import UIKit

class BlockListViewController: UIViewController {
    
    @IBOutlet weak var blockListTableView: UITableView!
    
    // Data Source
    var user: User?
    var users: [User] = []
    var blockList: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        blockListTableView.dataSource = self
        
        blockListTableView.delegate = self
        
        blockListTableView.registerCellWithNib(identifier: String(describing: BlockListTableViewCell.self), bundle: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        blockListTableView.reloadData()
    }
    
}

extension BlockListViewController: BlockListDelegate {
    
    func unblockUser(_ didselect: BlockListTableViewCell) {
        
        guard let indexPath = self.blockListTableView.indexPath(for: didselect) else { return }
        
        blockList.remove(at: indexPath.row)
        
        updateUser()
        
    }
    
    
    private func updateUser() {
        
        self.user?.blockUsers = []
        
        for blockedUser in blockList {
            
            self.user?.blockUsers.append(blockedUser.uid)
            
        }
        
        guard let  userToBeUpdated =  self.user else { return }
        
        UserManager.shared.updateUser(user: userToBeUpdated, uid: userToBeUpdated.uid) { result in
            
            switch result {
                
            case .success:
                
                self.blockListTableView.reloadData()
                
                print("解封鎖成功")
                
            case .failure:
                
                print("解封鎖失敗")
                
            }
        }
        
    }
    
}

extension BlockListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        blockList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let blockListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "BlockListTableViewCell", for: indexPath)
        guard let cell = blockListTableViewCell as? BlockListTableViewCell else { return blockListTableViewCell }
        let url = URL(string: blockList[indexPath.row].userAvatar)
        cell.delegate = self
        cell.userAvatar.kf.indicatorType = .activity
        cell.userAvatar.kf.setImage(with: url)
        cell.userName.text = blockList[indexPath.row].userName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
