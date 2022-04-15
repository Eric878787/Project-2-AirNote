//
//  UICollectionView+Extension.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/12.
//

import UIKit

extension UICollectionView {

    func registerCellWithNib(identifier: String, bundle: Bundle?) {

        let nib = UINib(nibName: identifier, bundle: bundle)

        register(nib, forCellWithReuseIdentifier: identifier)
    }
}
