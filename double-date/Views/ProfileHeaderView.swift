//
//  ProfileHeaderView.swift
//  double-date
//
//  Created by Robert Rozenvasser on 8/1/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

final class ProfileHeaderView: UIView {
    
    var containerView: UIView!
    var userImageView: UIImageView!
    var imageButton: UIButton!
    var nameLabel: UILabel!
    var nameSubLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupContainerView()
        setupStackView()
        setupImageButton()
    }
    
    func populateInfoWith(currentUser: User) {
//        if let imageData = currentUser.avatarImageData {
//            userImageView.image = UIImage(data: imageData)
//        }
        nameLabel.text = currentUser.name
        nameSubLabel.text = "SubLabel"
    }
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.white
        
        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
            make.height.equalTo(120)
        }
    }
    
    private func setupStackView() {
        userImageView = UIImageView()
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.cornerRadius = 72/2
        userImageView.layer.masksToBounds = true
        userImageView.backgroundColor = Palette.faintGrey.color
        userImageView.snp.makeConstraints { (make) in make.height.width.equalTo(72) }
        
        nameLabel = UILabel().rxStyle(font: FontBook.AvenirHeavy.of(size: 13), color: Palette.darkNavy.color, alignment: .center)
        nameSubLabel = UILabel().rxStyle(font: FontBook.AvenirHeavy.of(size: 13), color: Palette.lightBlue.color, alignment: .center)

        let views: [UIView] = [userImageView, nameLabel]
        let labelsStackView = UIStackView(arrangedSubviews: views)
        labelsStackView.spacing = 12.0
        labelsStackView.axis = .vertical
        labelsStackView.alignment = .center
        
        containerView.addSubview(labelsStackView)
        labelsStackView.snp.makeConstraints { (make) in
            make.top.centerX.equalTo(containerView)
        }
    }
    
    private func setupImageButton() {
        imageButton = UIButton()
        imageButton.backgroundColor = UIColor.clear
        
        containerView.addSubview(imageButton)
        imageButton.snp.makeConstraints { (make) in
            make.edges.equalTo(userImageView)
        }
    }
    
}
