//
//  EmptyView.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/22/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

final class EmptyView: UIView {
    
    var containerView: UIView!
    var titleLabel: UILabel!
    var button: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupContainerView()
        setupStackView()
    }
    
    func populateInfoWith(titleText: String, buttonText: String) {
        titleLabel.text = titleText
        button.setTitle(buttonText, for: .normal)
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
        
        button = UIButton()
        button.snp.makeConstraints { (make) in
            make.height.equalTo(60)
        }
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, button])
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
