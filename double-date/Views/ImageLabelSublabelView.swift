//
//  ImageLabelSublabelView.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/22/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

final class ImageLabelSublabelView: UIView {
    
    var userImageView: UIImageView!
    var topLabel: UILabel!
    var subLabel: UILabel!
    var alignment: NSTextAlignment = .left
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(imageWidth: CGFloat) {
        super.init(frame: .zero)
        setupUserImageView(width: imageWidth)
        setupNameLabelsStackView()
    }
 
    func populateInfoWith(topText: String?, subLabelText: String?) {
        topLabel.text = topText
        subLabel.text = subLabelText
    }
    
    private func setupUserImageView(width: CGFloat) {
        userImageView = UIImageView()
        userImageView.layer.cornerRadius = width/2
        userImageView.layer.masksToBounds = true
        userImageView.backgroundColor = Palette.faintGrey.color
        
        self.addSubview(userImageView)
        userImageView.snp.makeConstraints { (make) in
            make.left.centerY.equalTo(self)
            make.height.width.equalTo(width)
            make.top.bottom.equalTo(self)
        }
    }
    
    private func setupNameLabelsStackView() {
        topLabel = UILabel()
        topLabel.numberOfLines = 1
        topLabel.textAlignment = alignment
        
        subLabel = UILabel()
        subLabel.numberOfLines = 1
        subLabel.textAlignment = alignment
        
        let views: [UILabel] = [topLabel, subLabel]
        let labelsStackView = UIStackView(arrangedSubviews: views)
        labelsStackView.spacing = 2.0
        labelsStackView.axis = .vertical
        
        self.addSubview(labelsStackView)
        labelsStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(userImageView.snp.right).offset(10)
            make.right.equalTo(self)
        }
    }
    
}
