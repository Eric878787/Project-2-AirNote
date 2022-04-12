//
//  NotesManager.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/12.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class NotesManager {
    
    static let shared = NotesManager()
    
    lazy var db = Firestore.firestore()
    
    func fetchArticles(completion: @escaping (Result<[Note], Error>) -> Void) {
        
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
    
}
