//
//  AuthViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/27.
//

import UIKit

class AuthViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10
    }
    
    // MARK: Methods
    @IBAction func dissMiss(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    @IBAction func toLogInPage(_ sender: Any) {
        guard let viewController = UIStoryboard.auth.instantiateInitialViewController() else { return }
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true, completion: nil)
    }
    
}
