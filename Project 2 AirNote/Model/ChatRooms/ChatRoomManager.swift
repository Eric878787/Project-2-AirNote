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
    
    lazy var db = Firestore.firestore()
    
    static let shared = ChatRoomManager()
    
    
    func fetchRooms(completion: @escaping (Result<[ChatRoom], Error>) -> Void) {
        
        db.collection("ChatRooms").order(by: "createdTime", descending: true).getDocuments() { (querySnapshot, error) in
            
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                var rooms = [ChatRoom]()
                
                for document in querySnapshot!.documents {
                    
                    do {
                        if let room = try document.data(as: ChatRoom.self, decoder: Firestore.Decoder()) {
                            
                            rooms.append(room)
                                
                            
                        }
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                
                completion(.success(rooms))
            }
        }
    }
    
    
    func fetchRoomsWithUid(roomIds: [String], completion: @escaping (Result<[ChatRoom], Error>) -> Void) {
        
        db.collection("ChatRooms").order(by: "createdTime", descending: true).getDocuments() { (querySnapshot, error) in
            
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                var rooms = [ChatRoom]()
                
                for document in querySnapshot!.documents {
                    
                    do {
                        if let room = try document.data(as: ChatRoom.self, decoder: Firestore.Decoder()) {
                            
                            for roomId in roomIds where roomId == room.chatRoomId {
                            
                            rooms.append(room)
                                
                            }
                            
                        }
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                
                completion(.success(rooms))
            }
        }
    }
    
    func checkMessageChange(chatroomId: String, completion: @escaping (Result<ChatRoom, Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("ChatRooms").document(chatroomId).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else { return }
            var updatedChatRoom = ChatRoom(chatRoomId: "", groupId: "", messages: [], roomTitle: "", ownerId: "", createdTime: Date())
            do {
                if let chatRoom = try document.data(as: ChatRoom.self, decoder: Firestore.Decoder()) {
                    updatedChatRoom = chatRoom
                }
            } catch {
                completion(.failure(error))
            }
            completion(.success(updatedChatRoom))
        }
    }
    
    
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
        
        guard let uid = FirebaseManager.shared.currentUser?.uid else { return }
        
        do {
            room.ownerId = uid
            let date = Date()
            room.createdTime = date
            room.chatRoomId = document.documentID
            
            try  document.setData(from: room, encoder: Firestore.Encoder())
            completion(.success(document.documentID))
        }
        catch {
            completion(.failure(error))
        }
    }
    
    func updateChatRoomMessages(chatRoom: ChatRoom, chatRoomId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let msgRef = db.collection("ChatRooms").document(chatRoomId)
        var room = chatRoom
        do {
            try msgRef.setData(from: room, encoder: Firestore.Encoder())
            completion(.success("上傳成功"))
        }
        catch {
            completion(.failure(error))
        }
    }
    
    func deleteChatRoom(chatRoomId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let msgRef = db.collection("ChatRooms").document(chatRoomId)
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
