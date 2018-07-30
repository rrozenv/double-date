//
//  InvitationTableCell.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/30/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

final class InvitationTableCell: UITableViewCell {
    
    // MARK: - Properties
    static let defaultReusableId: String = "InvitationTableCell"
    private var containerView: UIView!
    private var headerView: UIView!
    private var headerLabel: UILabel!
    private var inviterNameLabel: UILabel!
    private var gameNameLabel: UILabel!
    
    
    private var percentReturnLabel: UILabel!
    private var cashReturnLabel: UILabel!
    private var limitPendingLabel: UILabel!
    
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
        setupLabels()
    }
    
    // MARK: - Configuration
    func configureWith(value: Invitation) {
        headerLabel.text = "You were invited..."
        inviterNameLabel.text = "\(value.sentBy.fullName)"
        gameNameLabel.text = "\(value.fundName)"
    }

}

extension InvitationTableCell {
    
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
            make.height.equalTo(100)
        }
    }
    
    private func setupHeaderView() {
        headerView = UIView()
        headerView.backgroundColor = Palette.faintBlue.color
        
        containerView.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(containerView)
            make.height.equalTo(40)
        }
    }
    
    private func setupLabels() {
        headerLabel = UILabel().rxStyle(font: FontBook.AvenirHeavy.of(size: 13), color: Palette.darkNavy.color, alignment: .left)
        headerLabel.lineBreakMode = .byTruncatingTail
        headerLabel.numberOfLines = 1
        headerView.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(headerView)
        }
        
        inviterNameLabel = UILabel().rxStyle(font: FontBook.AvenirHeavy.of(size: 13), color: Palette.darkNavy.color, alignment: .left)
        inviterNameLabel.numberOfLines = 1
        
        gameNameLabel = UILabel().rxStyle(font: FontBook.AvenirMedium.of(size: 12), color: Palette.aqua.color, alignment: .left)
        gameNameLabel.numberOfLines = 1
        
        let sv = UIStackView(arrangedSubviews: [inviterNameLabel, gameNameLabel])
        sv.axis = .vertical
        sv.spacing = 5.0
        
        containerView.addSubview(sv)
        sv.snp.makeConstraints { (make) in
            make.left.equalTo(containerView).offset(20)
            make.bottom.equalTo(containerView).offset(-10)
            make.top.equalTo(headerView).offset(10)
        }
    }
    
}
