//
//  FundTableCell.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/27/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class FundTableCell: UITableViewCell {
    
    // MARK: - Properties
    static let defaultReusableId: String = "FundTableCell"
    private var disposeBag = DisposeBag()
    private var containerView: UIView!
    private var mainLabel: UILabel!
    private var dateLabel: UILabel!
    private var countLabel: UILabel!
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
        self.contentView.backgroundColor = UIColor.white
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
        dateLabel.text = "Max \(value.maxPlayers) players"
        countLabel.text = "Return: \(value.currentUserPortfolio.portfolioROI.asPercentage)"
    }
    
    func configureWith(value: Position) {
        mainLabel.text = value.ticker
        dateLabel.text = "Entry: \(value.buyPrice)"
        countLabel.text = "Current: \(value.currentPrice.asCurreny)"
        rightLabel.text = "Total Value: \(value.totalPurchaseValue.asCurreny)"
    }
    
    func configureWith(value: Portfolio) {
        mainLabel.text = value.user.firstName
        dateLabel.text = "Entry: \(value.positions.map { $0.ticker }.joined(separator: ", "))"
        countLabel.text = "Return: \(value.portfolioROI * 100.0) %"
    }
    
    func configureWith(value: Invitation) {
        mainLabel.text = "You were invited to \(value.fundName) by \(value.sentBy.firstName)"
        dateLabel.text = "\(value.status.rawValue)"
    }
    
}

extension FundTableCell {

    //MARK: View Setup
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.green
        
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
    }
    
    private func setupNameLabelsStackView() {
        mainLabel = UILabel().rxStyle(font: FontBook.AvenirHeavy.of(size: 15), color: .black, alignment: .left)
        mainLabel.numberOfLines = 0
        
        dateLabel = UILabel().rxStyle(font: FontBook.AvenirMedium.of(size: 13), color: .black, alignment: .left)
        dateLabel.numberOfLines = 0
        
        countLabel = UILabel().rxStyle(font: FontBook.AvenirMedium.of(size: 13), color: .black, alignment: .left)
        countLabel.numberOfLines = 0
        
        let views: [UILabel] = [mainLabel, dateLabel, countLabel]
        let labelsStackView = UIStackView(arrangedSubviews: views)
        labelsStackView.spacing = 2.0
        labelsStackView.axis = .vertical
        
        containerView.addSubview(labelsStackView)
        labelsStackView.snp.makeConstraints { (make) in
            make.edges.equalTo(containerView)
        }
    }
    
    private func setupRightLabel() {
        rightLabel = UILabel().rxStyle(font: FontBook.AvenirMedium.of(size: 14), color: .black, alignment: .right)
        
        containerView.addSubview(rightLabel)
        rightLabel.snp.makeConstraints { (make) in
            make.right.equalTo(containerView.snp.right).offset(-20)
            make.centerY.equalTo(containerView)
        }
    }
    
}
