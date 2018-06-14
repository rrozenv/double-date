//
//  FontBook.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/13/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

enum FontBook: String {
    case AvenirMedium = "Avenir-Medium"
    case AvenirHeavy = "Avenir-Heavy"
    case AvenirBlack = "Avenir-Black"
    
    func of(size: CGFloat) -> UIFont {
        return UIFont(name: self.rawValue, size: size)!
    }
    
    static let buttonTitle = FontBook.AvenirHeavy.of(size: 14)
}
