//
//  AuthViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/27.
//

import UIKit

class AuthViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10
    }
    
    @IBAction func dissMiss(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    @IBAction func toLogInPage(_ sender: Any) {
        
        guard let vc = UIStoryboard.auth.instantiateInitialViewController() else { return }
        
        vc.modalPresentationStyle = .fullScreen

        present(vc, animated: true, completion: nil)
        
    }
}
