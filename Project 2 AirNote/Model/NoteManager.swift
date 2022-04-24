//
//  NotesManager.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/12.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage
import UIKit

class NoteManager {
    
    lazy var db = Firestore.firestore()
    
    func fetchNotes(completion: @escaping (Result<[Note], Error>) -> Void) {
        
        db.collection("Notes").order(by: "createdTime", descending: true).getDocuments() { (querySnapshot, error) in
            
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                var notes = [Note]()
                
                for document in querySnapshot!.documents {
                    
                    do {
                        if let note = try document.data(as: Note.self, decoder: Firestore.Decoder()) {
                            
                            notes.append(note)
                            
                        }
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                
                completion(.success(notes))
            }
        }
    }
    
    func createNote(note: Note, completion: @escaping (Result<String, Error>) -> Void) {
        
        let document = db.collection("Notes").document()
        
        var note = note
        
        do {
            note.authorId = "qbQsVVpVHlf6I4XLfOJ6"
            note.comments = []
            let date = Date()
            note.createdTime = date
            note.noteId = document.documentID
            note.likes = []
            note.clicks = []
            
            try  document.setData(from: note, encoder: Firestore.Encoder())
            completion(.success("上傳成功"))
        }
        catch {
            completion(.failure(error))
        }
        
    }
    
    func updateNote(note: Note, noteId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let msgRef = db.collection("Notes").document(noteId)
        var note = note
        do {
            try msgRef.setData(from: note, encoder: Firestore.Encoder())
            completion(.success("上傳成功"))
        }
        catch {
            completion(.failure(error))
        }
    }
    
    func deleteNote(noteId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let msgRef = db.collection("Notes").document(noteId)
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
