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

class NoteManager {
    
    static let shared = NoteManager()
    
    private init() {}
    
    lazy var dataBase = Firestore.firestore()
    
    func fetchNotes(completion: @escaping (Result<[Note], Error>) -> Void) {
        
        dataBase.collection("Notes").order(by: "createdTime", descending: true).getDocuments { (querySnapshot, error) in
                
            guard let querySnapshot = querySnapshot else {
                
                completion(.failure(error!))
                
                return
            }
                
                var notes = [Note]()
                
            for document in querySnapshot.documents {
                    
                    if let note = try? document.data(as: Note.self, decoder: Firestore.Decoder()) {
                    
                    notes.append(note)
                        
                    }
                    
                }
                
                completion(.success(notes))
        }
    }
    
    func fetchNote(_ noteId: String, completion: @escaping (Result<Note, Error>) -> Void) {
        
        dataBase.collection("Notes").document(noteId).getDocument { (document, error) in
            
            if let document = document, document.exists {
              
                var fetchedNote: Note?
                
                do {
                    
                    if let note = try? document.data(as: Note.self, decoder: Firestore.Decoder()) {
                        
                        fetchedNote = note
                        
                    }
                    
                } catch {
                    
                    completion(.failure(error))
                }
                
                guard let note = fetchedNote else { return }
                
                completion(.success(note))
                
            } else {
                
                guard let error = error else { return }
                
                completion(.failure(error))
                
            }
            
        }
        
    }
    
    func createNote(note: inout Note, completion: @escaping (Result<String, Error>) -> Void) {
        
        let document = dataBase.collection("Notes").document()
        
        guard let uid = FirebaseManager.shared.currentUser?.uid else { return }
        
        do {
            note.authorId = uid
            note.comments = []
            let date = Date()
            note.createdTime = date
            note.noteId = document.documentID
            note.likes = []
            note.clicks = []
            
            try  document.setData(from: note, encoder: Firestore.Encoder())
            completion(.success(document.documentID))
        }
        catch {
            completion(.failure(error))
        }
        
    }
    
    func updateNote(note: Note, noteId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let msgRef = dataBase.collection("Notes").document(noteId)
        let note = note
        do {
            try msgRef.setData(from: note, encoder: Firestore.Encoder())
            completion(.success("????????????"))
        }
        catch {
            completion(.failure(error))
        }
    }
    
    func deleteNote(noteId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let msgRef = dataBase.collection("Notes").document(noteId)
        do {
            try msgRef.delete()
            completion(.success("????????????"))
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
                completion(.failure(error!))
                return
            }
            riversRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(downloadURL))
            }
        }
    }
}
