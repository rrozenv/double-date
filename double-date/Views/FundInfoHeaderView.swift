//
//  FundInfoHeaderView.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/9/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

final class FundInfoHeaderView: UIView {
    
    var containerView: UIView!
    var titleLabel: UILabel!
    var subTitleLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupContainerView()
        setupStackView()
    }
    
    func populateInfoWith(titleText: String, subTitleText: String) {
        titleLabel.text = titleText
        subTitleLabel.text = subTitleText
    }
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = .white
        
        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    private func setupStackView() {
        titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        
        subTitleLabel = UILabel()
        subTitleLabel.numberOfLines = 0
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
        stackView.spacing = 10.0
        stackView.axis = .vertical
        
        containerView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.center.equalTo(containerView)
            make.left.equalTo(containerView).offset(26)
            make.right.equalTo(containerView).offset(-26)
        }
    }
    
}
