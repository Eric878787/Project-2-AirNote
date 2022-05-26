//
//  CafeManager.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/25.
//

import Foundation
import AVFoundation

class CafeManager {
    
    func fetchCafeInfo(_ completion: @escaping (Result<[Cafe], Error>) -> Void) {
        var cafes: [Cafe] = []
        if let url = URL(string: "https://cafenomad.tw/api/v1.2/cafes/taipei") {
           URLSession.shared.dataTask(with: url) { data, response, error in
              if let data = data {
                  
                  guard let httpResponse = response as? HTTPURLResponse else { return }
                  
                  let statusCode = httpResponse.statusCode

                  switch statusCode {

                  case 200..<300:
                      
                      do {
                         let result = try JSONDecoder().decode([Cafe].self, from: data)
                          for count in 0..<29 {
                              cafes.append(result[count])
                          }
                          DispatchQueue.main.async {
                              completion(Result.success(cafes))
                          }
                      } catch let error {
                          
                          completion(Result.failure(error))
                          
                      }

                  case 400..<500:

                      completion(Result.failure(HTTPClientError.clientError(data)))

                  case 500..<600:

                      completion(Result.failure(HTTPClientError.serverError))

                  default: return

                      completion(Result.failure(HTTPClientError.unexpectedError))
                  }
               }
           }.resume()
        }
    }
    
}

enum HTTPClientError: Error {

    case decodeDataFail

    case clientError(Data)

    case serverError

    case unexpectedError
}
