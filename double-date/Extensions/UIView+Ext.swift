//
//  UIView+Ext.swift
//  HousePartyApp
//
//  Created by Robert Rozenvasser on 5/24/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func dropShadow(scale: Bool = true) {
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 5
    }
    
}

extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}

struct ButtonStyle {
    let title: String?
    let enabledBackgroundColor: UIColor?
    let disabledBackgroundColor: UIColor?
    let enabledTitleColor: UIColor?
    let disabledTitleColor: UIColor?
    let image: UIImage?
    let font: UIFont?
    let contentEdgeInsets: UIEdgeInsets
    let cornerRadius: CGFloat
    let isHidden: Bool
    let isEnabled: Bool
    
    init(title: String? = nil,
         enabledBackgroundColor: UIColor? = .clear,
         disabledBackgroundColor: UIColor? = .clear,
         enabledTitleColor: UIColor? = nil,
         disabledTitleColor: UIColor? = nil,
         image: UIImage? = nil,
         font: UIFont? = nil,
         contentEdgeInsets: UIEdgeInsets = .zero,
         cornerRadius: CGFloat = 0.0,
         isHidden: Bool = false,
         isEnabled: Bool = true) {
        self.title = title
        self.enabledBackgroundColor = enabledBackgroundColor
        self.disabledBackgroundColor = disabledBackgroundColor
        self.enabledTitleColor = enabledTitleColor
        self.disabledTitleColor = disabledTitleColor
        self.image = image
        self.font = font
        self.contentEdgeInsets = contentEdgeInsets
        self.cornerRadius = cornerRadius
        self.isHidden = isHidden
        self.isEnabled = isEnabled
    }
}

final class StyledButton: UIButton {
    
    var style: ButtonStyle {
        didSet {
            self.setTitle(style.title, for: .normal)
            self.backgroundColor = style.isEnabled ? style.enabledBackgroundColor : style.disabledBackgroundColor
            self.setImage(style.image?.withRenderingMode(.alwaysOriginal), for: .normal)
            self.imageView?.contentMode = .scaleAspectFit
            self.setTitleColor(style.isEnabled ? style.enabledTitleColor : style.disabledTitleColor, for: .normal)
            self.titleLabel?.font = style.font
            self.contentEdgeInsets = style.contentEdgeInsets
            self.isHidden = style.isHidden
            self.isEnabled = style.isEnabled
        }
    }
    
    init(frame: CGRect = .zero, style: ButtonStyle = ButtonStyle()) {
        self.style = style
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

