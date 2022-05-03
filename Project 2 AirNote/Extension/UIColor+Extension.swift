//
//  UIColor+Extension.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/5/2.
//

import UIKit

extension UIColor {

    static let myBrown = UIColor(red: 64/255, green: 56/255 ,blue: 53/255, alpha: 1)

    static let myBeige = UIColor(red: 250/255, green: 250/255 ,blue: 250/255, alpha: 1)

    static let myDarkGreen = UIColor(red: 32/255, green: 123/255 ,blue: 110/255, alpha: 1)

    static let myLightGreen = UIColor(red: 100/255, green: 120/255 ,blue: 119/255, alpha: 1)

    static let myPurple =  UIColor(red: 177/255, green: 162/255 ,blue: 167/255, alpha: 1)
    
    static func hexStringToUIColor(hex: String) -> UIColor {

        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if (cString.count) != 6 {
            return UIColor.gray
        }

        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
