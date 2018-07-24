//
//  UserContactTableCell.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/22/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

final class UserContactTableCell: UITableViewCell, ValueCell {
    
    // MARK: - Properties
    typealias Value = ContactViewModel
    static var defaultReusableId: String = "UserContactTableCell"
    private var containerView: UIView!
    private var mainLabel: UILabel!
    private var imageNameSublabelView: ImageLabelSublabelView!
    private var circleBorderView: UIView!
    private var iconImageView: UIImageView!
    
    var isSelect: Bool = false {
        didSet {
            iconImageView.isHidden = !isSelect
        }
    }
    
    // MARK: - Initialization
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.contentView.backgroundColor = UIColor.white
        self.selectionStyle = .none
        setupContainerView()
        setupCirleBorderView()
        setupIconImageView()
        setupUserImageNameSublabelView()
    }
    
    // MARK: - Configuration
    func configureWith(value: ContactViewModel) {
        imageNameSublabelView.topLabel.text = value.contact.fullName
        imageNameSublabelView.subLabel.text = value.contact.primaryNumber ?? value.contact.numbers.first!
        isSelect = value.isSelected
    }
    
    func configureWith(value: FundViewModel) {
        imageNameSublabelView.topLabel.text = value.fund.name
        //imageNameSublabelView.subLabel.text = "\(value.fund.maxPlayers)"
        isSelect = value.isSelected
    }
    
}

extension UserContactTableCell {
    
    //MARK: View Setup
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.white
        
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
    }
    
    private func setupCirleBorderView() {
        circleBorderView = UIView()
        circleBorderView.layer.borderWidth = 2.0
        circleBorderView.layer.borderColor = Palette.lightGrey.color.cgColor
        circleBorderView.layer.cornerRadius = 20/2
        circleBorderView.layer.masksToBounds = true
        circleBorderView.backgroundColor = UIColor.white
        
        containerView.addSubview(circleBorderView)
        circleBorderView.snp.makeConstraints { (make) in
            make.right.equalTo(containerView).offset(-26)
            make.centerY.equalTo(containerView)
            make.height.width.equalTo(20)
        }
    }
    
    private func setupIconImageView() {
        iconImageView = UIImageView()
        //iconImageView.isHidden = true
        iconImageView.image = #imageLiteral(resourceName: "IC_CheckMark")
        
        containerView.insertSubview(iconImageView, aboveSubview: circleBorderView)
        iconImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(circleBorderView)
        }
    }
    
    private func setupUserImageNameSublabelView() {
        imageNameSublabelView = ImageLabelSublabelView(imageWidth: 50.0)
        
        containerView.addSubview(imageNameSublabelView)
        imageNameSublabelView.snp.makeConstraints { (make) in
            make.top.equalTo(containerView).offset(10)
            make.bottom.equalTo(containerView).offset(-10)
            make.left.equalTo(containerView).offset(26)
            make.right.equalTo(circleBorderView).offset(-26)
        }
    }
    
}
