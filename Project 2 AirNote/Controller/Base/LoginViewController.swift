//
//  LoginViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/26.
//

import UIKit
import AuthenticationServices

class LoginViewController: UIViewController {
    
    private var signInWithAppleButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
    
    // User Manager
    private var userManager = UserManager()
    private var existingUsers: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSignInWithAppleButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}

extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        
        return view.window!
        
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        FirebaseSignInManager.shared.authorizationController(controller: controller, didCompleteWithAuthorization: authorization)
    }
    
    func configureSignInWithAppleButton() {
        
        signInWithAppleButton.translatesAutoresizingMaskIntoConstraints = false
        signInWithAppleButton.cornerRadius = 5
        signInWithAppleButton.addTarget(self, action: #selector(signInWithApple), for: .touchUpInside)
        view.addSubview(signInWithAppleButton)
        
        NSLayoutConstraint.activate([
            signInWithAppleButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            signInWithAppleButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            signInWithAppleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
    }
    
    @objc private func signInWithApple() {
        
        let request = FirebaseSignInManager.shared.performSignIn()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        
        FirebaseSignInManager.shared.loginSucess = {
            
            guard let vc = UIStoryboard.main.instantiateInitialViewController() else { return }
                    
            self.present(vc, animated: true)
            
        }
    
    }
    
}
