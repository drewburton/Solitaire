//
//  Utils.swift
//  Solitaire
//
//  Created by Drew Burton on 10/29/24.
//

import UIKit

let scaleFactor = UIScreen.main.bounds.height / 667.0

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: alpha )
    }
}

func scaled(value: CGFloat) -> CGFloat {
    return  value * scaleFactor
}
