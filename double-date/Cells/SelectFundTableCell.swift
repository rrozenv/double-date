//
//  SelectFundTableCell.swift
//  double-date
//
//  Created by Robert Rozenvasser on 8/15/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class SelectFundTableCell: UITableViewCell {
    
    // MARK: - Properties
    static let defaultReusableId: String = "SelectFundTableCell"
    private var containerView: UIView!
    private var mainLabel: UILabel!
    private var dateLabel: UILabel!
    private var rightLabel: UILabel!
    private var circleBorderView: UIView!
    private var iconImageView: UIImageView!
    
    var didSelect: Bool = false {
        didSet { iconImageView.isHidden = !didSelect }
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
        self.contentView.backgroundColor = Palette.appBackground.color
        self.separatorInset = .zero
        self.preservesSuperviewLayoutMargins = false
        self.layoutMargins = .zero
        self.selectionStyle = .none
        setupContainerView()
        setupNameLabelsStackView()
        setupCirleBorderView()
        setupIconImageView()
    }
    
    // MARK: - Configuration
    func configureWith(value: FundViewModel) {
        mainLabel.text = value.fund.name
        dateLabel.text = "\(value.fund.daysLeft) days left"
        didSelect = value.isSelected
    }
    
}

extension SelectFundTableCell {
    
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
        iconImageView.image = #imageLiteral(resourceName: "IC_CheckMark")
        
        containerView.insertSubview(iconImageView, aboveSubview: circleBorderView)
        iconImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(circleBorderView)
        }
    }
    
}
