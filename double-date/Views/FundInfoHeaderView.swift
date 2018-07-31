//
//  FundInfoHeaderView.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/9/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

final class FundDetailsHeaderView: UIView {
    
    var topLeftLabel: UILabel!
    var bottomLeftLabel: UILabel!
    var topRightLabel: UILabel!
    var bottomRightLabel: UILabel!
    var containerView: UIView!
    var containerStackView: CustomStackView<UIView>!
    var height: CGFloat = 85
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupContainerView()
        setupContainerStackView()
        setupLeftLabelStackView()
        setupRightLabelStackView()
    }
    
    func populateInfoWith(netEquity: String, returnPercentage: String) {
        topLeftLabel.text = netEquity
        topRightLabel.text = returnPercentage
        bottomLeftLabel.text = "net equity"
        bottomRightLabel.text = "return"
    }
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = Palette.aqua.color
        
        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
            make.height.equalTo(height)
        }
    }
    
    private func setupContainerStackView() {
        containerStackView = CustomStackView<UIView>(number: 3, stackViewProps: StackViewProps(axis: .horizontal, distribution: .fillEqually, spacing: 0))
        
        containerView.addSubview(containerStackView)
        containerStackView.snp.makeConstraints { (make) in
            make.left.right.equalTo(containerView).inset(26)
            make.centerY.equalTo(containerView)
        }
    }
    
    private func setupLeftLabelStackView() {
        topLeftLabel = UILabel().rxStyle(font: FontBook.AvenirMedium.of(size: 16), color: .white, alignment: .center)
        bottomLeftLabel = UILabel().rxStyle(font: FontBook.AvenirHeavy.of(size: 11), color: Palette.darkNavy.color, alignment: .center)
        
        let sv = UIStackView(arrangedSubviews: [topLeftLabel, bottomLeftLabel])
        sv.axis = .vertical
        sv.spacing = 2.0
        
        let leftView = containerStackView.item(at: 0)
        leftView.addSubview(sv)
        sv.snp.makeConstraints { (make) in
            make.edges.equalTo(leftView)
        }
    }
    
    private func setupRightLabelStackView() {
        topRightLabel = UILabel().rxStyle(font: FontBook.AvenirMedium.of(size: 16), color: .white, alignment: .center)
        bottomRightLabel = UILabel().rxStyle(font: FontBook.AvenirHeavy.of(size: 11), color: Palette.darkNavy.color, alignment: .center)
        
        let sv = UIStackView(arrangedSubviews: [topRightLabel, bottomRightLabel])
        sv.axis = .vertical
        sv.spacing = 2.0
        
        let rightView = containerStackView.item(at: 2)
        rightView.addSubview(sv)
        sv.snp.makeConstraints { (make) in
            make.edges.equalTo(rightView)
        }
    }

}

//final class FundInfoHeaderView: UIView {
//
//    var containerView: UIView!
//    var headerView: FundDetailsHeaderView!
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    init() {
//        super.init(frame: .zero)
//        setupContainerView()
//        setupHeaderView()
//    }
//
//    func populateInfoWith(titleText: String, subTitleText: String) {
////        titleLabel.text = titleText
////        subTitleLabel.text = subTitleText
//    }
//
//    private func setupContainerView() {
//        containerView = UIView()
//        containerView.backgroundColor = .white
//
//        self.addSubview(containerView)
//        containerView.snp.makeConstraints { (make) in
//            make.edges.equalTo(self)
//            make.height.equalTo(160)
//        }
//    }
//
//    private func setupHeaderView() {
//        headerView = FundDetailsHeaderView()
//
//        containerView.addSubview(headerView)
//        headerView.snp.makeConstraints { (make) in
//            make.left.right.equalTo(containerView)
//            make.centerY.equalTo(containerView)
//        }
//    }
//
//}
