//
//  BackButtonNavView.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/16/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

final class BackButtonNavView: UIView {
    
    var containerView: UIView!
    var backButton: UIButton!
    
    //MARK: Initalizer Setup
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(backButtonImage: UIImage, imageSize: CGSize, leftMargin: CGFloat) {
        super.init(frame: .zero)
        self.backgroundColor = .clear
        setupContainerView()
        setupBackButton(image: backButtonImage, imageSize: imageSize, leftMargin: leftMargin)
    }
    
    func style(backgroundColor: UIColor, backButtonImage: UIImage) {
        containerView.backgroundColor = backgroundColor
    }
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.white
        
        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    private func setupBackButton(image: UIImage, imageSize: CGSize, leftMargin: CGFloat) {
        backButton = UIButton.paddedImageButton(image: image,
                                                imageSize: imageSize,
                                                left: leftMargin,
                                                top: 15,
                                                bottom: 15,
                                                right: 20)
        
        containerView.addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(containerView)
        }
    }
    
}

extension BackButtonNavView {
    static var blackArrow: BackButtonNavView {
        return BackButtonNavView(backButtonImage: #imageLiteral(resourceName: "IC_BackArrow_Black"),
                                 imageSize: CGSize(width: 9, height: 17),
                                 leftMargin: 26.0)
    }
}
