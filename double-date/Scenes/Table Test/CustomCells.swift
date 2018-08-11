//
//  CustomCells.swift
//  double-date
//
//  Created by Robert Rozenvasser on 8/7/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

class UserCell: UITableViewCell, ConfigurableCell {
    
    var containerView = UIView()
    var userNameLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        setupContainerView()
    }
    
    func configure(data color: UIColor) {
        containerView.backgroundColor = color
    }
    
    private func setupContainerView() {
        contentView.addSubview(containerView)
        containerView.fillSuperview()
        containerView.anchor(heightConstant: 60)
    }
    
}

class RandomCell: UITableViewCell, ConfigurableCell {
    
    var containerView = UIView()
    var userNameLabel = UILabel()
    var button = UIButton()
    static let userFollowAction = "UserFollowAction"
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        setupContainerView()
        setupLabel()
        setupButton()
    }
    
    private func setupContainerView() {
        containerView.backgroundColor = .white
        contentView.addSubview(containerView)
        containerView.fillSuperview()
        containerView.anchor(heightConstant: 60)
    }
    
    private func setupLabel() {
        containerView.addSubview(userNameLabel)
        userNameLabel.anchorCenterSuperview()
    }
    
    private func setupButton() {
        button = button.setup(title: "Custom",
                              backgroundColor: .red,
                              titleColor: .white,
                              target: self,
                              selector: #selector(onButtonTap))
        containerView.addSubview(button)
        button.anchor(right: contentView.rightAnchor, rightConstant: 20, widthConstant: 100, heightConstant: 40)
        button.anchorCenterYToSuperview()
    }
    
    func configure(data text: String) {
        containerView.backgroundColor = .green
        userNameLabel.text = text
        userNameLabel.textColor = .black
    }
    
    @objc func onButtonTap(_ sender: Any) {
        CellAction.custom(type(of: self).userFollowAction).invoke(cell: self)
    }
    
}

final class TableHeaderView: UITableViewHeaderFooterView, ConfigurableCell {
    
    var containerView = UIView()
    var userNameLabel = UILabel()
    var button = UIButton()
    static let headerAction = "headerAction"
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupContainerView()
        setupLabel()
        setupButton()
    }
    
    private func setupContainerView() {
        containerView.backgroundColor = .white
        contentView.addSubview(containerView)
        containerView.fillSuperview()
        containerView.anchor(heightConstant: 100)
    }
    
    private func setupLabel() {
        containerView.addSubview(userNameLabel)
        userNameLabel.anchorCenterSuperview()
    }
    
    func configure(data text: String) {
        userNameLabel.text = text
        userNameLabel.textColor = .black
    }
    
    private func setupButton() {
        button = button.setup(title: "Header But",
                              backgroundColor: .red,
                              titleColor: .white,
                              target: self,
                              selector: #selector(onButtonTap))
        containerView.addSubview(button)
        button.anchor(right: containerView.rightAnchor,rightConstant: 20, widthConstant: 100, heightConstant: 40)
        button.anchorCenterYToSuperview()
    }
    
    @objc func onButtonTap(_ sender: Any) {
        CellAction.custom(type(of: self).headerAction).invoke(cell: self)
    }
    
}
