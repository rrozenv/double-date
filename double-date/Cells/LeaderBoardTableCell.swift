//
//  LeaderBoardTableCell.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/30/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class LeaderBoardTableCell: UITableViewCell {
    
    // MARK: - Properties
    static let defaultReusableId: String = "LeaderBoardTableCell"
    private var containerView: UIView!
    private var nameLabel: UILabel!
    private var countLabel: UILabel!
    private var returnLabel: UILabel!
    private var countBackgroundView: UIView!
    
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
        self.contentView.backgroundColor = Palette.appBackground.color
        self.separatorInset = .zero
        self.preservesSuperviewLayoutMargins = false
        self.layoutMargins = .zero
        self.selectionStyle = .none
        setupContainerView()
        setupCount()
        setupNameLabel()
        setupReturnLabel()
    }
    
    // MARK: - Configuration
    func configureWith(value: Portfolio, index: Int) {
        nameLabel.text = value.user.firstName
        countLabel.text = "\(index)"
        returnLabel.text = "\(value.portfolioROI.asPercentage)"
    }
    
}

extension LeaderBoardTableCell {
    
    //MARK: View Setup
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 2.0
        containerView.layer.masksToBounds = true
        containerView.dropShadow()
        
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(20)
            make.right.equalTo(contentView).offset(-20)
            make.top.equalTo(contentView).offset(10)
            make.bottom.equalTo(contentView).offset(-10)
            make.height.equalTo(70)
        }
    }
    
    private func setupCount() {
        let backgroundWidth: CGFloat = 34.0
        countBackgroundView = UIView()
        countBackgroundView.backgroundColor = Palette.faintBlue.color
        countBackgroundView.layer.cornerRadius = backgroundWidth/2
        
        countLabel = UILabel().rxStyle(font: FontBook.AvenirHeavy.of(size: 12), color: .white, alignment: .center)
        countBackgroundView.addSubview(countLabel)
        countLabel.snp.makeConstraints { (make) in
            make.center.equalTo(countBackgroundView)
        }
        
        containerView.addSubview(countBackgroundView)
        countBackgroundView.snp.makeConstraints { (make) in
            make.centerY.equalTo(containerView)
            make.left.equalTo(containerView).offset(20)
        }
    }
    
    private func setupNameLabel() {
        nameLabel = UILabel().rxStyle(font: FontBook.AvenirHeavy.of(size: 13), color: Palette.darkNavy.color, alignment: .left)
        containerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(containerView)
            make.left.equalTo(countBackgroundView).offset(20)
        }
    }
    
    private func setupReturnLabel() {
        returnLabel = UILabel().rxStyle(font: FontBook.AvenirHeavy.of(size: 13), color: Palette.darkNavy.color, alignment: .left)
        
        containerView.addSubview(returnLabel)
        returnLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(containerView)
            make.left.equalTo(containerView).offset(-20)
        }
    }
    
}
