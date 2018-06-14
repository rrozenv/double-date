//
//  UIButton+Ext.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/13/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    static func paddedImageButton(image: UIImage,
                                  imageSize: CGSize = CGSize(width: 10.0, height: 10.0),
                                  left: CGFloat = 20.0,
                                  top: CGFloat = 20.0,
                                  bottom: CGFloat = 20.0,
                                  right: CGFloat = 20.0) -> UIButton {
        image.size.equalTo(CGSize(width: imageSize.width, height: imageSize.height))
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        button.setImage(image, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: top,
                                                left: left,
                                                bottom: bottom,
                                                right: right)
        return button
    }
    
}

extension UIButton {
    
    func style(title: String = "",
               font: UIFont = FontBook.AvenirHeavy.of(size: 14),
               backColor: UIColor = Palette.aqua.color,
               titleColor: UIColor = .white) {
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = font
        self.backgroundColor = backColor
        self.setTitleColor(titleColor, for: .normal)
    }
    
    func rxStyle(title: String = "",
                 font: UIFont,
                 backColor: UIColor = Palette.aqua.color,
                 titleColor: UIColor = .white) -> UIButton {
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = font
        self.backgroundColor = backColor
        self.setTitleColor(titleColor, for: .normal)
        return self
    }
    
}

struct LabelStyle {
    let font: UIFont
    let color: UIColor
    let alignment: NSTextAlignment
    let numberOfLines: Int
}

extension UILabel {
    
    convenience init(title: String) {
        self.init(frame: CGRect.zero)
        self.text = title
    }
    
    func style(font: UIFont, color: UIColor, alignment: NSTextAlignment = .center) {
        self.font = font
        self.textColor = color
        self.textAlignment = alignment
    }
    
    func styleWith(_ style: LabelStyle) {
        self.font = style.font
        self.textColor = style.color
        self.textAlignment = style.alignment
        self.numberOfLines = style.numberOfLines
    }
    
    func rxStyle(font: UIFont, color: UIColor, alignment: NSTextAlignment = .center) -> UILabel {
        self.font = font
        self.textColor = color
        self.textAlignment = alignment
        return self
    }
    
}

extension UITextField {
    
    func style(placeHolder: String?, font: UIFont?, backColor: UIColor?, titleColor: UIColor) {
        self.placeholder = placeHolder
        self.backgroundColor = backColor
        self.font = font
        self.textColor = titleColor
    }
    
}
