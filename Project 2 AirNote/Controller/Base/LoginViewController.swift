//
//  LoginViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/26.
//

import UIKit
import AuthenticationServices

class LoginViewController: BaseViewController {
    
    // MARK: Propertires
    private var signInWithAppleButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
    private var asVisitorButton = UIButton()
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var termsAndConditionsStackView: UIStackView!
    private var existingUsers: [User] = []
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        configureSignInWithAppleButton()
        configureAsVisitorButton()
        configureNativeSignIn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.layer.cornerRadius = 5
        emailTextField.clipsToBounds = true
        passwordTextField.layer.cornerRadius = 5
        passwordTextField.clipsToBounds = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutingSubviews()
        
    }
    
    // MARK: Methods
    @IBAction func nativeSignUp(_ sender: Any) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        FirebaseManager.shared.nativeSignUp(email, password)
        FirebaseManager.shared.signUpSuccess = {
            self.checkIfItsNew()
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
            self.showBasicConfirmationAlert("註冊成功", "請重新登入")
        }
        
        FirebaseManager.shared.signUpFailure = { errorMessage in
            self.checkIfItsNew()
            self.showBasicConfirmationAlert("註冊失敗", "\(self.handlingErrorMessage(errorMessage))")
        }
    }
    
    @IBAction func nativeLogIn(_ sender: Any) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        FirebaseManager.shared.nativeLogIn(email, password)
        FirebaseManager.shared.loginSuccess = {
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
            self.showBasicConfirmationAlert("登入成功", "") {
                self.presentOrDismissVC()
            }
        }
        
        FirebaseManager.shared.logInFailure = { errorMessage in
            self.showBasicConfirmationAlert("登入失敗", "\(self.handlingErrorMessage(errorMessage))")
        }
        
    }
    
    @IBAction func openPrivacy(_ sender: Any) {
        let viewController = WebViewController()
        viewController.urlString = "https://pages.flycricket.io/airnote/privacy.html"
        self.present(viewController, animated: true)
    }
    
    @IBAction func openEULA(_ sender: Any) {
        let viewController = WebViewController()
        viewController.urlString = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
        self.present(viewController, animated: true)
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    private func handlingErrorMessage(_ errorMessage: String) -> String {
        switch errorMessage {
        case "There is no user record corresponding to this identifier. The user may have been deleted." :
            return "用戶不存在"
        case "The email address is badly formatted." :
            return "請輸入正確Email密碼錯誤"
        case "The password is invalid or the user does not have a password.":
            return "密碼錯誤"
        case "The password must be 6 characters long or more.":
            return "密碼不得少於6個字元"
        case "The email address is already in use by another account.":
            return "此Email已被註冊"
        default:
            return "未知的錯誤"
        }
    }
    
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
        signUpButton.layer.cornerRadius = 5
        signUpButton.clipsToBounds = true
        
        // Log In Button
        logInButton.setTitle("登入", for: .normal)
        logInButton.setTitleColor(.systemGray2, for: .disabled)
        logInButton.setTitleColor(.black, for: .normal)
        logInButton.titleLabel?.font =  UIFont(name: "PingFangTC-Regular", size: 16)
        logInButton.backgroundColor = .systemGray6
        logInButton.layer.cornerRadius = 5
        logInButton.clipsToBounds = true
        logInButton.isEnabled = false
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
            asVisitorButton.bottomAnchor.constraint(equalTo: signInWithAppleButton.topAnchor, constant: -20)
        ])
        
    }
    
    func configureSignInWithAppleButton() {
        signInWithAppleButton.translatesAutoresizingMaskIntoConstraints = false
        signInWithAppleButton.cornerRadius = 5
        signInWithAppleButton.addTarget(self, action: #selector(signInWithApple), for: .touchUpInside)
        view.addSubview(signInWithAppleButton)
        NSLayoutConstraint.activate([
            signInWithAppleButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                           constant: 30),
            signInWithAppleButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                            constant: -30),
            signInWithAppleButton.bottomAnchor.constraint(equalTo: termsAndConditionsStackView.topAnchor,
                                                          constant: -10)
        ])
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if emailTextField.text?.count != 0 && passwordTextField.text?.count != 0 {
            logInButton.backgroundColor = .white
            logInButton.isEnabled = true
        } else {
            logInButton.backgroundColor = .systemGray6
            logInButton.isEnabled = false
        }
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

extension LoginViewController {
    
    @objc private func accessAsVisitor() {
        presentOrDismissVC()
    }
    
    func presentOrDismissVC () {
        guard let viewController = UIStoryboard.main.instantiateInitialViewController() else { return }
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true)
    }
    
}

// MARK: Sign in with Apple
extension LoginViewController: ASAuthorizationControllerDelegate,
                               ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        // To trigger the function defined in class FirebaseManager
        FirebaseManager.shared.authorizationController(controller: controller,
                                                       didCompleteWithAuthorization: authorization)
    }
    
    @objc private func signInWithApple() {
        let request = FirebaseManager.shared.signInWithApple()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        FirebaseManager.shared.loginSuccess = {
            self.checkIfItsNew()
            self.showBasicConfirmationAlert("登入成功", "") {
                self.presentOrDismissVC()
            }
        }
        FirebaseManager.shared.logInFailure = { errorMessage in
            self.showBasicConfirmationAlert("登入失敗", "\(self.handlingErrorMessage(errorMessage))")
        }
    }
    
}
