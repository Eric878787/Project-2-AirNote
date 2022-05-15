//
//  FirebaseSingInManager.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/26.
//

import AuthenticationServices
import Firebase
import FirebaseAuth
import CryptoKit

class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    var currentUser = Auth.auth().currentUser
    
    var authenticator = Auth.auth()
    
    var loginSuccess: (() -> Void)?
    
    var signUpSuccess: (() -> Void)?
    
    var logInFailure: ((String) -> Void)?
    
    var signUpFailure: ((String) -> Void)?
    
    var deleteAccountSuccess: (() -> Void)?
    
}


// MARK: Native Sign In & Out
extension FirebaseManager {
    
    func nativeSignUp(_ email: String, _ password: String) {
        authenticator.createUser(withEmail: email, password: password) { result, error in
            guard let user = result?.user, error == nil
            else {
                print("======\(error?.localizedDescription)")
                self.signUpFailure?(error?.localizedDescription ?? "unknowned failure")
                return
            }
            self.signUpSuccess?()
        }
    }
    
    func nativeLogIn(_ email: String, _ password: String) {
        authenticator.signIn(withEmail: email, password: password) { result, error in
            guard let user = result?.user,
                  error == nil else {
                print("========\(error?.localizedDescription)")
                self.logInFailure?(error?.localizedDescription ?? "unknowned failure")
                return
            }
            self.loginSuccess?()
        }
    }
    
    func signout() {
        do {
            try authenticator.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func delete() {
        currentUser?.delete { error in
          if let error = error {
              print(error.localizedDescription)
          } else {
              self.deleteAccountSuccess?()
          }
        }
    }
    
}

// MARK: Sign in With Apple
extension FirebaseManager {
    
    func signInWithApple() -> ASAuthorizationAppleIDRequest  {
        
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        return request
        
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            // Sign in with Apple.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let user = authResult?.user {
                    self.loginSuccess?()
                    return
                }
                self.logInFailure?(error?.localizedDescription ?? "unknowned failure")
                return
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
        
    }
    
}

// MARK: Nonce & sha256 generating function
extension FirebaseManager {
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
}
