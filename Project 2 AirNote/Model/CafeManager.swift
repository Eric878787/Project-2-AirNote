//
//  CafeManager.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/25.
//

import Foundation


class CafeManager {
    
    func fetchCafeInfo(_ completion: @escaping ([Cafe]) -> Void) {
        var cafes: [Cafe] = []
        if let url = URL(string: "https://cafenomad.tw/api/v1.2/cafes/taipei") {
           URLSession.shared.dataTask(with: url) { data, response, error in
              if let data = data {
                  do {
                     let result = try JSONDecoder().decode([Cafe].self, from: data)
                      for count in 0..<19 {
                          cafes.append(result[count])
                      }
                      DispatchQueue.main.async {
                          completion(cafes)
                      }
                  } catch let error {
                     print(error)
                  }
               }
           }.resume()
        }
    }
    
}
