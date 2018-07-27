//
//  PositionSummaryTableCell.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/26/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class PositionSummaryTableCell: UITableViewCell {
    
    // MARK: - Properties
    static let defaultReusableId: String = "PositionSummaryTableCell"
    private var containerView: UIView!
    private var symbolLabel: UILabel!
    private var sharesLabel: UILabel!
    private var totalValueLabel: UILabel!
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
        setupLeftStackView()
        setupRightStackView()
    }
    
    // MARK: - Configuration
    func configureWith(value: Position) {
        symbolLabel.text = value.ticker
        sharesLabel.text = "\(value.shares) shares @"
        totalValueLabel.text = "\(value.buyPrice.asCurreny)"
        percentReturnLabel.text = "\(value.positionROI.asPercentage)"
        cashReturnLabel.text = "\(value.profitLossDouble.asCurreny)"
        
        limitPendingLabel.text = "\(value.isPendingBuy ? "Limit Order Pending" : "")"
        limitPendingLabel.isHidden = value.isPendingBuy ? false : true
        percentReturnLabel.isHidden = value.isPendingBuy
        cashReturnLabel.isHidden = value.isPendingBuy
    }
    
}

extension PositionSummaryTableCell {
    
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
            make.height.equalTo(80)
        }
    }
    
    private func setupLeftStackView() {
        // Top right
        symbolLabel = UILabel().rxStyle(font: FontBook.AvenirHeavy.of(size: 13), color: Palette.darkNavy.color, alignment: .left)
        symbolLabel.lineBreakMode = .byTruncatingTail
        symbolLabel.numberOfLines = 1
        
        // Bottom left stack view
        sharesLabel = UILabel().rxStyle(font: FontBook.AvenirMedium.of(size: 12), color: Palette.lightGrey.color, alignment: .left)
        sharesLabel.numberOfLines = 1
        
        totalValueLabel = UILabel().rxStyle(font: FontBook.AvenirMedium.of(size: 12), color: Palette.lightGrey.color, alignment: .left)
        totalValueLabel.numberOfLines = 1
        
        let sharesValueSv = UIStackView(arrangedSubviews: [sharesLabel, totalValueLabel])
        sharesValueSv.axis = .horizontal
        sharesValueSv.spacing = 5.0
        
        // Right container stack view
        let labelsStackView = UIStackView(arrangedSubviews: [symbolLabel, sharesValueSv])
        labelsStackView.spacing = 5.0
        labelsStackView.axis = .vertical
        
        containerView.addSubview(labelsStackView)
        labelsStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(containerView)
            make.left.equalTo(containerView).offset(20)
        }
    }
    
    private func setupRightStackView() {
        // Top left
        percentReturnLabel = UILabel().rxStyle(font: FontBook.AvenirHeavy.of(size: 14), color: Palette.aqua.color, alignment: .left)
        percentReturnLabel.numberOfLines = 1
        
        // Bottom left stack view
        cashReturnLabel = UILabel().rxStyle(font: FontBook.AvenirMedium.of(size: 12), color: Palette.aqua.color, alignment: .left)
        cashReturnLabel.numberOfLines = 1
        
        // Right container stack view
        let labelsStackView = UIStackView(arrangedSubviews: [percentReturnLabel, cashReturnLabel])
        labelsStackView.spacing = 5.0
        labelsStackView.axis = .vertical
        
        containerView.addSubview(labelsStackView)
        labelsStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(containerView)
            make.right.equalTo(containerView).offset(-20)
        }
        
        limitPendingLabel = UILabel().rxStyle(font: FontBook.AvenirMedium.of(size: 12), color: Palette.aqua.color)
        containerView.addSubview(limitPendingLabel)
        limitPendingLabel.snp.makeConstraints { (make) in
            make.right.equalTo(containerView).offset(-20)
            make.centerY.equalTo(containerView)
        }
    }
    
}
