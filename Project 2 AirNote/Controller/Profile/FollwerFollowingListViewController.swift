//
//  FollwerFollowingListViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/5/15.
//

import UIKit

class FollwerFollowingListViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    
    // Data
    var userList: [User] = []
    var navItemTitle =  ""
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        self.navigationItem.title = navItemTitle
        tableView.registerCellWithNib(identifier: String(describing: BlockListTableViewCell.self), bundle: nil)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
}

extension FollwerFollowingListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let blockListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "BlockListTableViewCell", for: indexPath)
        guard let cell = blockListTableViewCell as? BlockListTableViewCell else { return blockListTableViewCell }
        let url = URL(string: userList[indexPath.row].userAvatar)
        cell.userAvatar.kf.indicatorType = .activity
        cell.userAvatar.kf.setImage(with: url)
        cell.userName.text = userList[indexPath.row].userName
        cell.unblockButton.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: "OtherProfileViewController") as? OtherProfileViewController else { return }
        viewController.userInThisPage = userList[indexPath.row]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
