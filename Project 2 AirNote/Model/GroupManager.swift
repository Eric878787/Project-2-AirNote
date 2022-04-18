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
    
    static let shared = GroupManager()
    
    lazy var db = Firestore.firestore()
    
    func fetchGroups(completion: @escaping (Result<[Group], Error>) -> Void) {
        
        db.collection("Groups").order(by: "createdTime", descending: true).getDocuments() { (querySnapshot, error) in
            
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                var groups = [Group]()
                
                for document in querySnapshot!.documents {
                    
                    do {
                        if let group = try document.data(as: Group.self, decoder: Firestore.Decoder()) {
                            
                            groups.append(group)
                            
                        }
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                
                completion(.success(groups))
            }
        }
    }
    
    func createGroup(group: Group, completion: @escaping (Result<String, Error>) -> Void) {
        
        let document = db.collection("Groups").document()
        
        var group = group
        
        do {
            group.groupOwner = "qbQsVVpVHlf6I4XLfOJ6"
            group.groupMembers.append("qbQsVVpVHlf6I4XLfOJ6")
            let date = Date()
            group.createdTime = date
            group.groupId = document.documentID
            
            try  document.setData(from: group, encoder: Firestore.Encoder())
            completion(.success("上傳成功"))
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
    
}
