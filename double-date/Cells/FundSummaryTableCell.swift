//
//  FundSummaryTableCell.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/26/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class FundSummaryTableCell: UITableViewCell {
    
    // MARK: - Properties
    static let defaultReusableId: String = "FundSummaryTableCell"
    private var containerView: UIView!
    private var mainLabel: UILabel!
    private var dateLabel: UILabel!
    private var rightLabel: UILabel!
    
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
        setupNameLabelsStackView()
        setupRightLabel()
    }
    
    // MARK: - Configuration
    func configureWith(value: Fund) {
        mainLabel.text = value.name
        dateLabel.text = "\(value.daysLeft) days left"
        rightLabel.text = "\(value.currentUserPortfolio.portfolioROI.asPercentage)"
    }
    
    func configureWith(value: NewsArticle) {
        mainLabel.text = value.headline
        dateLabel.text = value.source
    }
    
    func configureWith(value: Quote) {
        mainLabel.text = value.companyName
        dateLabel.text = value.symbol
    }
    
}

extension FundSummaryTableCell {
    
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
    
    private func setupNameLabelsStackView() {
        mainLabel = UILabel().rxStyle(font: FontBook.AvenirHeavy.of(size: 13), color: Palette.darkNavy.color, alignment: .left)
        mainLabel.lineBreakMode = .byTruncatingTail
        mainLabel.numberOfLines = 1
        mainLabel.lineBreakMode = .byTruncatingTail
        
        dateLabel = UILabel().rxStyle(font: FontBook.AvenirMedium.of(size: 12), color: Palette.lightGrey.color, alignment: .left)
        dateLabel.numberOfLines = 1
        
        let views: [UILabel] = [mainLabel, dateLabel]
        let labelsStackView = UIStackView(arrangedSubviews: views)
        labelsStackView.spacing = 5.0
        labelsStackView.axis = .vertical
        
        containerView.addSubview(labelsStackView)
        labelsStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(containerView)
            make.left.equalTo(containerView).offset(20)
            make.right.equalTo(containerView).offset(-20)
        }
    }
    
    private func setupRightLabel() {
        rightLabel = UILabel().rxStyle(font: FontBook.AvenirMedium.of(size: 15), color: Palette.aqua.color, alignment: .right)
        
        containerView.addSubview(rightLabel)
        rightLabel.snp.makeConstraints { (make) in
            make.right.equalTo(containerView.snp.right).offset(-20)
            make.centerY.equalTo(containerView)
        }
    }
    
}
