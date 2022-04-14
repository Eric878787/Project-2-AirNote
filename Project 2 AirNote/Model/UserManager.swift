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
    
}
