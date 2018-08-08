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
    
    var userNameLabel = UILabel()
    
    func configure(data color: UIColor) {
        contentView.backgroundColor = color
    }
    
}

class RandomCell: UITableViewCell, ConfigurableCell {
    
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
        setupLabel()
        setupButton()
    }
    
    private func setupLabel() {
        contentView.addSubview(userNameLabel)
        userNameLabel.anchorCenterSuperview()
    }
    
    private func setupButton() {
        button = button.setup(title: "Custom",
                              backgroundColor: .red,
                              titleColor: .white,
                              target: self,
                              selector: #selector(onButtonTap))
        contentView.addSubview(button)
        button.anchor(right: contentView.rightAnchor,rightConstant: 20, widthConstant: 100, heightConstant: 40)
        button.anchorCenterYToSuperview()
    }
    
    func configure(data text: String) {
        contentView.backgroundColor = .green
        userNameLabel.text = text
        userNameLabel.textColor = .black
    }
    
    @objc func onButtonTap(_ sender: Any) {
        CellAction.custom(type(of: self).userFollowAction).invoke(cell: self)
    }
    
}

final class TableHeaderView: UIView, ConfigurableCell {
    
    var containerView = UIView()
    var userNameLabel = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupContainerView()
        setupLabel()
    }
    
    private func setupContainerView() {
        containerView.backgroundColor = .white
        self.addSubview(containerView)
        containerView.fillSuperview()
        containerView.anchor(heightConstant: 60)
    }
    
    private func setupLabel() {
        containerView.addSubview(userNameLabel)
        userNameLabel.anchorCenterSuperview()
    }
    
    func configure(data text: String) {
        userNameLabel.text = text
        userNameLabel.textColor = .black
    }
    
}
