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
    
    func createUser(_ user: inout User, _ documentId: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        let document = db.collection("Users").document(documentId)
        
        guard let uid = FirebaseManager.shared.currentUser?.uid else { return }
        
        do {
            
            try  document.setData(from: user, encoder: Firestore.Encoder())
            completion(.success("上傳成功"))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        
        db.collection("Users").order(by: "userName", descending: true).getDocuments() { (querySnapshot, error) in
            
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                var users = [User]()
                
                for document in querySnapshot!.documents {
                    
                    if let user = try? document.data(as: User.self, decoder: Firestore.Decoder()) {
                    
                    users.append(user)
                        
                    }
                    
                }
                
                completion(.success(users))
            }
        }
    }
    
    func fetchUser(_ uid: String, completion: @escaping (Result<User?, Error>) -> Void) {
        
        db.collection("Users").document(uid).getDocument { (document, error) in
            
            if let error = error {
                
                completion(.failure(error))
                
            } else {
                
                var fetchedUser: User?
                
                do {
                    
                    if let user = try document?.data(as: User.self, decoder: Firestore.Decoder()) {
                        
                        fetchedUser = user
                        
                    }
                    
                } catch {
                    
                    completion(.failure(error))
                }
                
                completion(.success(fetchedUser))
                
            }
            
        }
        
    }
    
    func updateUser(user: User, uid: String, completion: @escaping (Result<String, Error>) -> Void) {
        let msgRef = db.collection("Users").document(uid)
        var user = user
        do {
            try msgRef.setData(from: user, encoder: Firestore.Encoder())
            completion(.success("上傳成功"))
        }
        catch {
            completion(.failure(error))
        }
    }
    
    func deleteGroup(uids: [String], groupId: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        for uid in uids {
            do {
                let ref = db.collection("Users").document(uid)
                ref.updateData([
                    "joinedGroups": FieldValue.arrayRemove([groupId])
                ])
            }
            catch {
                completion(.failure(error))
            }
        }
        completion(.success("刪除成功"))
    }
    
    func deleteOwnGroup(uid: String, groupId: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        do {
            let ref = db.collection("Users").document(uid)
            ref.updateData([
                "userGroups": FieldValue.arrayRemove([groupId])
            ])
            completion(.success("刪除成功"))
        }
        catch {
            completion(.failure(error))
        }
    }
    
    func uploadPhoto(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        
        let riversRef = Storage.storage().reference().child(UUID().uuidString + ".jpg")
        
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        let uploadTask = riversRef.putData(data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                print("upload failed")
                return
            }
            riversRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print("download url failed")
                    return
                }
                completion(.success(downloadURL))
            }
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
