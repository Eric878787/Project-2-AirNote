//
//  BlockListViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/5/4.
//

import UIKit

class BlockListViewController: BaseViewController {
    
    // MARK: Properties
    @IBOutlet weak var blockListTableView: UITableView!
    var user: User?
    var users: [User] = []
    var blockList: [User] = []
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        blockListTableView.separatorStyle = .none
        blockListTableView.dataSource = self
        blockListTableView.delegate = self
        self.navigationItem.title = "封鎖用戶"
        blockListTableView.registerCellWithNib(identifier: String(describing: BlockListTableViewCell.self), bundle: nil)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        blockListTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
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
        guard let userToBeUpdated =  self.user else { return }
        UserManager.shared.updateUser(user: userToBeUpdated, uid: userToBeUpdated.uid) { result in
            switch result {
            case .success:
                self.blockListTableView.reloadData()
            case .failure:
                self.showBasicConfirmationAlert("解除封鎖失敗", "請檢查網路連線")
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
