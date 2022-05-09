//
//  UISegmentedControl.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/5/4.
//

import UIKit

extension UISegmentedControl {

    func setup() {
            backgroundColor = .clear

            // Use a clear image for the background and the dividers
            let tintColorImage = UIImage(color: .clear, size: CGSize(width: 1, height: 32))
            setBackgroundImage(tintColorImage, for: .normal, barMetrics: .default)
            setDividerImage(tintColorImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)

        }
    
}

extension UIImage {
    convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        color.set()
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        self.init(data: image.pngData()!)!
    }
}
