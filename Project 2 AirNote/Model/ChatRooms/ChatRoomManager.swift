//
//  GroupManager.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/20.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage
import UIKit

class ChatRoomManager {
    
    static let shared = GroupManager()
    
    lazy var db = Firestore.firestore()
    
    func checkRoomsChange(completion: @escaping (Result<[ChatRoom], Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("ChatRooms").addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            var chatRooms = [ChatRoom]()
            snapshot.documents.forEach { document in
                do {
                    if let chatRoom = try document.data(as: ChatRoom.self, decoder: Firestore.Decoder()) {
                        chatRooms.append(chatRoom)
                    }
                } catch {
                    completion(.failure(error))
                }
            }
            completion(.success(chatRooms))
        }
    }
    
    func createChatRoom(chatRoom: ChatRoom, completion: @escaping (Result<String, Error>) -> Void) {
        
        let document = db.collection("ChatRooms").document()
        
        var room = chatRoom
        
        do {
            room.ownerId = "qbQsVVpVHlf6I4XLfOJ6"
            let date = Date()
            room.createdTime = date
            room.chatRoomId = document.documentID
            
            try  document.setData(from: room, encoder: Firestore.Encoder())
            completion(.success("上傳成功"))
        }
        catch {
            completion(.failure(error))
        }
        
    }
    //
    //    func uploadPhoto(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
    //
    //        let riversRef = Storage.storage().reference().child(UUID().uuidString + ".jpg")
    //
    //        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
    //
    //        let uploadTask = riversRef.putData(data, metadata: nil) { (metadata, error) in
    //            guard let metadata = metadata else {
    //                print("upload failed")
    //                return
    //            }
    //            riversRef.downloadURL { (url, error) in
    //                guard let downloadURL = url else {
    //                    print("download url failed")
    //                    return
    //                }
    //                completion(.success(downloadURL))
    //            }
    //        }
    //    }
    
}
