//
//  GroupManager.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/18.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage
import UIKit

class GroupManager {
    
    lazy var db = Firestore.firestore()
    
    static let shared = GroupManager()
    
    func fetchGroups(completion: @escaping (Result<[Group], Error>) -> Void) {
        
        db.collection("Groups").order(by: "createdTime", descending: true).getDocuments() { (querySnapshot, error) in
            
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                var groups = [Group]()
                
                for document in querySnapshot!.documents {
                    
                    if let group = try? document.data(as: Group.self, decoder: Firestore.Decoder()) {
                    
                    groups.append(group)
                        
                    }
                }
                
                completion(.success(groups))
            }
        }
    }
    
    func fetchSpecificGroups(groupIds: [String], completion: @escaping (Result<[Group], Error>) -> Void) {
        
        var fetchedGroups: [Group] = []
        
        for groupId in groupIds {
            
            db.collection("Groups").document(groupId).getDocument { (document, error) in
                
                if let error = error {
                    
                    completion(.failure(error))
                    
                } else {
                    
                    do {
                        
                        if let group = try document?.data(as: Group.self, decoder: Firestore.Decoder()) {
                            
                            fetchedGroups.append(group)
                            
                        }
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                    
                }
                
                if fetchedGroups.count == groupIds.count {
                
                completion(.success(fetchedGroups))
                    
                }
                
            }
            
        }
        
    }
    
    func checkMessageChange(groupId: String, completion: @escaping (Result<Group?, Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("Groups").document(groupId).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else { return }
            var updatedGroup: Group?
            do {
                let group = try document.data(as: Group.self, decoder: Firestore.Decoder())
                    updatedGroup = group
            } catch {
                completion(.failure(error))
            }
            completion(.success(updatedGroup))
        }
    }
    
    func updateGroup(group: Group, groupId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let msgRef = db.collection("Groups").document(groupId)
        do {
            try msgRef.setData(from: group, encoder: Firestore.Encoder())
            completion(.success("上傳成功"))
        }
        catch {
            completion(.failure(error))
        }
    }
    
    func createGroup(group: Group, completion: @escaping (Result<String, Error>) -> Void) {
        
        let document = db.collection("Groups").document()
        
        var group = group
        
        guard let uid = FirebaseManager.shared.currentUser?.uid else { return }
        
        do {
            group.groupOwner = uid
            group.groupMembers.append(uid)
            let date = Date()
            group.createdTime = date
            group.groupId = document.documentID
            
            try  document.setData(from: group, encoder: Firestore.Encoder())
            completion(.success(document.documentID))
        }
        catch {
            completion(.failure(error))
        }
        
    }
    
    func deleteGroup(groupId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let msgRef = db.collection("Groups").document(groupId)
        do {
            try msgRef.delete()
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
                return
            }
            riversRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    return
                }
                completion(.success(downloadURL))
            }
        }
    }
    
}
