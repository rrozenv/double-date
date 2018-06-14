//
//  UIStackView+Ext.swift
//  HousePartyApp
//
//  Created by Robert Rozenvasser on 5/11/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

extension UIStackView {
    
    static func dynamicWidth(itemCount: Int,
                             itemWidth: CGFloat,
                             spacing: CGFloat) -> CGFloat {
        let spacing: CGFloat = spacing
        let spacingMultiplier = CGFloat(itemCount - 1)
        let widthMultiplier = CGFloat(itemCount)
        return (spacing * spacingMultiplier) + (itemWidth * widthMultiplier)
    }
    
}
