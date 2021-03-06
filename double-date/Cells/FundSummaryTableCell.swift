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
        rightLabel.text = "\(value.currentUserPortfolio.portfolioROI.asPercentage)"
        rightLabel.textColor = value.currentUserPortfolio.portfolioROI >= 0 ? Palette.aqua.color : Palette.purple.color
        switch value.status {
        case .open: dateLabel.text = "\(value.daysLeft ?? 0) days left"
        case .pending: dateLabel.text = "Starts on \(value.startDate.dayMonthYearString)"
        case .completed: dateLabel.text = "Game completed on \(value.endDate.dayMonthYearString)"
        }
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
        containerView.constrainAsShadowBox()
        containerView.snp.makeConstraints { $0.height.equalTo(80) }
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
        rightLabel = UILabel().rxStyle(font: FontBook.AvenirHeavy.of(size: 15), color: Palette.aqua.color, alignment: .right)
        
        containerView.addSubview(rightLabel)
        rightLabel.snp.makeConstraints { (make) in
            make.right.equalTo(containerView.snp.right).offset(-20)
            make.centerY.equalTo(containerView)
        }
    }
    
}

extension UIView {
    
    func constrainAsShadowBox() {
        self.layer.cornerRadius = 2.0
        self.layer.masksToBounds = true
        self.dropShadow()
        
        self.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
}
