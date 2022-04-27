//
//  UsersManager.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/12.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class UserManager {
    
    static let shared = UserManager()
    
    lazy var db = Firestore.firestore()
    
    func fetchUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        
        db.collection("Users").order(by: "userName", descending: true).getDocuments() { (querySnapshot, error) in
            
                if let error = error {
                    
                    completion(.failure(error))
                } else {
                    
                    var users = [User]()
                    
                    for document in querySnapshot!.documents {

                        do {
                            if let user = try document.data(as: User.self, decoder: Firestore.Decoder()) {
                                
                                    users.append(user)
                                
                            }
                            
                        } catch {
                            
                            completion(.failure(error))
                        }
                    }
                    
                    completion(.success(users))
                }
        }
    }
    
    func updateUser(user: User, userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let msgRef = db.collection("Users").document(userId)
        var user = user
        do {
            try msgRef.setData(from: user, encoder: Firestore.Encoder())
            completion(.success("上傳成功"))
        }
        catch {
            completion(.failure(error))
        }
    }
    
    func createUser(_ user: inout User, _ documentId: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        let document = db.collection("Users").document(documentId)
        
        guard let uid = FirebaseManager.shared.currentUser?.uid else { return }
        
        do {
            
            try  document.setData(from: user, encoder: Firestore.Encoder())
            completion(.success("上傳成功"))
        }
        catch {
            completion(.failure(error))
        }
    }
    
    func deleteUser(uid: String, completion: @escaping (Result<String, Error>) -> Void) {
        let msgRef = db.collection("Users").document(uid)
        do {
            try msgRef.delete()
            completion(.success("刪除成功"))
        }
        catch {
            completion(.failure(error))
        }
    }
    
}
