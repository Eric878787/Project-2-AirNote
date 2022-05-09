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
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var logInButton: UIButton!
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var mainTitle: UILabel!
    
    
    // User Manager
    private var existingUsers: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSignInWithAppleButton()
        configureAsVisitorButton()
        configureNativeSignIn()
//        layoutingSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // refresh textfield border
        emailTextField.layer.borderColor = UIColor.clear.cgColor
        emailTextField.layer.cornerRadius = 10
        emailTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor.clear.cgColor
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.cornerRadius = 10
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutingSubviews()
        
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
            action.setValue(UIColor.black, forKey: "titleTextColor")
            controller.addAction(action)
            self.present(controller, animated: true)
        }
        
        FirebaseManager.shared.signUpFailure = {
            self.checkIfItsNew()
            let controller = UIAlertController(title: "註冊失敗", message: "請重新輸入帳號密碼", preferredStyle: .alert)
            controller.view.tintColor = UIColor.gray
            let action = UIAlertAction(title: "確認", style: .destructive)
            action.setValue(UIColor.black, forKey: "titleTextColor")
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
            action.setValue(UIColor.black, forKey: "titleTextColor")
            controller.addAction(action)
            self.present(controller, animated: true)
        }
        
        FirebaseManager.shared.logInFailure = {
            let controller = UIAlertController(title: "登入失敗", message: "", preferredStyle: .alert)
            controller.view.tintColor = UIColor.gray
            let action = UIAlertAction(title: "確認", style: .destructive)
            action.setValue(UIColor.black, forKey: "titleTextColor")
            controller.addAction(action)
            self.present(controller, animated: true)
        }
        
    }
    
}

// MARK: Configure Layouts
extension LoginViewController {
    
    private func layoutingSubviews () {
        
        // BackGround View
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = backgroundView.bounds
        gradientLayer.colors = [UIColor.myDarkGreen.cgColor, UIColor.myBeige.cgColor]
        backgroundView.layer.addSublayer(gradientLayer)
        
        // Sign In Button
        signUpButton.setTitle("註冊", for: .normal)
        signUpButton.setTitleColor(.black, for: .normal)
        signUpButton.titleLabel?.font =  UIFont(name: "PingFangTC-Regular", size: 16)
        signUpButton.backgroundColor = .white
        signUpButton.layer.cornerRadius = 10
        signUpButton.clipsToBounds = true
        
        // Log In Button
        logInButton.setTitle("登入", for: .normal)
        logInButton.setTitleColor(.black, for: .normal)
        logInButton.titleLabel?.font =  UIFont(name: "PingFangTC-Regular", size: 16)
        logInButton.backgroundColor = .white
        logInButton.layer.cornerRadius = 10
        logInButton.clipsToBounds = true
        
    }
    
    func showAlert(_ textfiled: UITextField) {
        
        textfiled.layer.borderColor = UIColor.red.cgColor
        textfiled.layer.borderWidth = 1
        
    }
    
    func configureNativeSignIn() {
        signUpButton.setTitle("註冊", for: .normal)
        logInButton.setTitle("登入", for: .normal)
        
    }
    
    func configureAsVisitorButton() {
        
        asVisitorButton.translatesAutoresizingMaskIntoConstraints = false
        asVisitorButton.layer.cornerRadius = 5
        asVisitorButton.clipsToBounds = true
        asVisitorButton.backgroundColor = .white
        asVisitorButton.setTitle("以訪客身份進入", for: .normal)
        asVisitorButton.titleLabel?.font =  UIFont(name: "PingFangTC-Regular", size: 14)
        asVisitorButton.setTitleColor(.black, for: .normal)
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
                    
                    var user = User(followers: [],
                                    followings: [],
                                    joinedGroups: [],
                                    savedNotes: [],
                                    userAvatar: "https://firebasestorage.googleapis.com/v0/b/project-2-airnote.appspot.com/o/user.png?alt=media&token=b1b20ce5-44f7-4351-93d3-e5c6903efa7f",
                                    userGroups: [],
                                    userName: "新用戶",
                                    userNotes: [],
                                    email: FirebaseManager.shared.currentUser?.email,
                                    uid: uid,
                                    blockUsers: [])
                    
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
            action.setValue(UIColor.black, forKey: "titleTextColor")
            controller.addAction(action)
            self.present(controller, animated: true)
        }
        
    }
    
}

// MARK: Presenting or dismissing vc
extension LoginViewController {
    
    func presentOrDismissVC () {
        
        guard let vc = UIStoryboard.main.instantiateInitialViewController() else { return }
        
        vc.modalPresentationStyle = .fullScreen
        
        self.present(vc, animated: true)
        
    }
    
}
