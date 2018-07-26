//
//  StockSearchTableCell.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/26/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class StockSearchTableCell: UITableViewCell {
    
    // MARK: - Properties
    static let defaultReusableId: String = "StockSearchTableCell"
    private var containerView: UIView!
    private var mainLabel: UILabel!
    private var dateLabel: UILabel!
    
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
    }
    
    // MARK: - Configuration
    func configureWith(value: Stock) {
        mainLabel.text = value.quote.symbol
        dateLabel.text = value.quote.companyName
    }
    
    func configureWith(value: StockSummary) {
        mainLabel.text = value.symbol
        dateLabel.text = value.companyName
    }
    
}

extension StockSearchTableCell {
    
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
    
    private func setupNameLabelsStackView() {
        mainLabel = UILabel().rxStyle(font: FontBook.AvenirHeavy.of(size: 13), color: Palette.darkNavy.color, alignment: .left)
        mainLabel.lineBreakMode = .byTruncatingTail
        mainLabel.numberOfLines = 1
        
        dateLabel = UILabel().rxStyle(font: FontBook.AvenirMedium.of(size: 12), color: Palette.lightGrey.color, alignment: .left)
        dateLabel.lineBreakMode = .byTruncatingTail
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
    
}
