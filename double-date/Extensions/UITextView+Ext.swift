//
//  UITextView+Ext.swift
//  HousePartyApp
//
//  Created by Robert Rozenvasser on 5/16/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

struct VaryingFontInfo {
    let originalText: String
    let fontDict: [String: UIFont]
    let fontColor: UIColor
}

extension UILabel {
    
    func varyingFonts(info: VaryingFontInfo) {
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        let attributedOriginalText = NSMutableAttributedString(string: info.originalText)
        
        info.fontDict.forEach {
            let linkRange = attributedOriginalText.mutableString.range(of: $0.key)
            attributedOriginalText.addAttribute(NSAttributedStringKey.font, value: $0.value, range: linkRange)
        }
        
        let fullRange = NSMakeRange(0, attributedOriginalText.length)
        attributedOriginalText.addAttribute(NSAttributedStringKey.paragraphStyle, value: style, range: fullRange)
        
        self.attributedText = attributedOriginalText
    }
    
}
