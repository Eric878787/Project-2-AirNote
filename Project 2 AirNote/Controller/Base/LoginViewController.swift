//
//  LoginViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/26.
//

import UIKit
import AuthenticationServices

class LoginViewController: UIViewController {
    
    // UI Properties
    private var signInWithAppleButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
    
    private var asVisitorButton = UIButton()
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var logInButton: UIButton!
    
    // User Manager
    private var existingUsers: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSignInWithAppleButton()
        configureAsVisitorButton()
        configureNativeSignIn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: Native Sign up
    @IBAction func nativeSignUp(_ sender: Any) {
        
        guard let email = emailTextField.text else { return }
        
        guard let password = passwordTextField.text else { return }
        
        if email == "" {
            
            showAlert(emailTextField)
            
        } else {
            
            if password.count < 6 {
                
                showAlert(passwordTextField)
                
            } else {
                
                FirebaseManager.shared.nativeSignUp(email, password)
                
            }
            
        }
        
        FirebaseManager.shared.signUpSuccess = {
            self.checkIfItsNew()
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
            let controller = UIAlertController(title: "註冊成功", message: "請重新登入", preferredStyle: .alert)
            controller.view.tintColor = UIColor.gray
            let action = UIAlertAction(title: "確認", style: .destructive)
            controller.addAction(action)
            self.present(controller, animated: true)
        }
        
        FirebaseManager.shared.signUpFailure = {
            self.checkIfItsNew()
            let controller = UIAlertController(title: "註冊失敗", message: "請重新輸入帳號密碼", preferredStyle: .alert)
            controller.view.tintColor = UIColor.gray
            let action = UIAlertAction(title: "確認", style: .destructive)
            controller.addAction(action)
            self.present(controller, animated: true)
        }
        
    }
    
    // MARK: Native Log In
    @IBAction func nativeLogIn(_ sender: Any) {
        
        guard let email = emailTextField.text else { return }
        
        guard let password = passwordTextField.text else { return }
        
        if email == "" {
            
            showAlert(emailTextField)
            
        } else {
            
            if password.count < 6 {
                
                showAlert(passwordTextField)
                
            } else {
                FirebaseManager.shared.nativeLogIn(email, password)
            }
            
        }
        
        FirebaseManager.shared.loginSuccess = {
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
            let controller = UIAlertController(title: "登入成功", message: "", preferredStyle: .alert)
            controller.view.tintColor = UIColor.gray
            let action = UIAlertAction(title: "確認", style: .destructive) { _ in
                self.presentOrDismissVC()
            }
            controller.addAction(action)
            self.present(controller, animated: true)
        }
        
        FirebaseManager.shared.logInFailure = {
            let controller = UIAlertController(title: "登入失敗", message: "", preferredStyle: .alert)
            controller.view.tintColor = UIColor.gray
            let action = UIAlertAction(title: "確認", style: .destructive)
            controller.addAction(action)
            self.present(controller, animated: true)
        }
        
    }
    
}

// MARK: Configure Layouts
extension LoginViewController {
    
    func showAlert(_ textfiled: UITextField) {
        
        textfiled.layer.borderColor = UIColor.red.cgColor
        textfiled.layer.borderWidth = 1
        
    }
    
    func configureNativeSignIn() {
        
        emailLabel.text = "帳號"
        passwordLabel.text = "密碼"
        signUpButton.setTitle("註冊", for: .normal)
        logInButton.setTitle("登入", for: .normal)
        
        
    }
    
    func configureAsVisitorButton() {
        
        asVisitorButton.translatesAutoresizingMaskIntoConstraints = false
        asVisitorButton.layer.cornerRadius = 5
        asVisitorButton.clipsToBounds = true
        asVisitorButton.backgroundColor = .systemGray6
        asVisitorButton.setTitle("以訪客身份進入", for: .normal)
        asVisitorButton.addTarget(self, action: #selector(accessAsVisitor), for: .touchUpInside)
        view.addSubview(asVisitorButton)
        
        NSLayoutConstraint.activate([
            asVisitorButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            asVisitorButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            asVisitorButton.bottomAnchor.constraint(equalTo: signInWithAppleButton.bottomAnchor, constant: -50)
        ])
        
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
    
}

// MARK: Check if it's new
extension LoginViewController {
    
    private func checkIfItsNew() {
        
        guard let uid = FirebaseManager.shared.currentUser?.uid else { return }
        
        var isNew = true
        
        UserManager.shared.fetchUsers { result in
            switch result {
            case .success(let users):
                self.existingUsers = users
                for user in self.existingUsers where user.uid == uid {
                    isNew = false
                }
                
                if isNew == true {
                    
                    var user = User(chatRooms: [],
                                    followers: [],
                                    followings: [],
                                    joinedGroups: [],
                                    savedNotes: [],
                                    userAvatar: "",
                                    userGroups: [],
                                    userId: "",
                                    userName: "",
                                    userNotes: [],
                                    email: FirebaseManager.shared.currentUser?.email,
                                    uid: uid)
                    
                    UserManager.shared.createUser( &user, uid) { result in
                        switch result {
                        case .success(let success):
                            print(success)
                        case .failure(let failure):
                            print(failure)
                        }
                    }
                    
                } else {
                    return
                }
                
            case.failure(let error):
                print(error)
            }
        }
        
    }
    
}

// MARK: As Visitor
extension LoginViewController {
    
    @objc private func accessAsVisitor() {
        
        presentOrDismissVC ()
        
    }
    
}


// MARK: Sign in with Apple
extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        
        return view.window!
        
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        // To trigger the function defined in class FirebaseManager
        FirebaseManager.shared.authorizationController(controller: controller, didCompleteWithAuthorization: authorization)
        
    }
    
    
    @objc private func signInWithApple() {
        
        let request = FirebaseManager.shared.signInWithApple()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        
        FirebaseManager.shared.loginSuccess = {
            self.checkIfItsNew()
            let controller = UIAlertController(title: "登入成功", message: "", preferredStyle: .alert)
            controller.view.tintColor = UIColor.gray
            let action = UIAlertAction(title: "確認", style: .destructive) { _ in
                self.presentOrDismissVC ()
            }
            controller.addAction(action)
            self.present(controller, animated: true)
        }
        
    }
    
}

// MARK: Presenting or dismissing vc
extension LoginViewController {
    
    func presentOrDismissVC () {
        
        if self.presentingViewController == nil {
            
            guard let vc = UIStoryboard.main.instantiateInitialViewController() else { return }
            
            vc.modalPresentationStyle = .fullScreen
            
            self.present(vc, animated: true)
            
        } else {
            
            self.dismiss(animated: true)
            
        }
        
    }
    
}
