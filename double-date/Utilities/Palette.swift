//
//  Palette.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/13/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

enum Palette {
    case appBackground, aqua, lightGrey, faintGrey, lightBlue, faintBlue, darkGrey, darkNavy, purple
    
    var color: UIColor {
        switch self {
        case .appBackground: return UIColor(hex: 0xFCFEFF)
        case .lightGrey: return UIColor(hex: 0xC0C0C0)
        case .faintGrey: return UIColor(hex: 0xFAFAFA)
        case .darkGrey: return UIColor(hex: 0x717171)
        case .darkNavy: return UIColor(hex: 0x2D3C44)
        case .lightBlue: return UIColor(hex: 0x8FA8B5)
        case .faintBlue: return UIColor(hex: 0xCAD5DA)
        case .purple: return UIColor(hex: 0x68669F)
        case .aqua: return UIColor(hex: 0x32DEA4)
        }
    }
}

extension UIColor {
    
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
    
    class func forGradient(_ red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
    
}
