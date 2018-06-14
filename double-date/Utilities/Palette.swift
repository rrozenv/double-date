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
    case aqua, maroon, lightGrey, faintGrey, mustard, darkGrey, brightYellow, darkYellow, red, darkNavy, purple
    
    var color: UIColor {
        switch self {
        case .maroon: return UIColor(hex: 0xBD7C7C)
        case .lightGrey: return UIColor(hex: 0xD2D2D2)
        case .faintGrey: return UIColor(hex: 0xF3F3F3)
        case .mustard: return UIColor(hex: 0xD4B06D)
        case .darkGrey: return UIColor(hex: 0x717171)
        case .brightYellow: return UIColor(hex: 0xFCDF1D)
        case .darkYellow: return UIColor(hex: 0x94712D)
        case .red: return UIColor(hex: 0xF25D5D)
        case .darkNavy: return UIColor(hex: 0x0B0A1F)
        case .purple: return UIColor(hex: 0x68669F)
        case .aqua: return UIColor(hex: 0x73C3BA)
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
