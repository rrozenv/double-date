//
//  CustomNavViewable.swift
//  DesignatedHitter
//
//  Created by Robert Rozenvasser on 4/20/18.
//  Copyright © 2018 Blueprint. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

protocol CustomNavBarViewable: class {
    associatedtype View: UIView
    var navView: View { get set }
    var navBackgroundView: UIView { get set }
    func setupNavBar(height: CGFloat, color: UIColor?)
    func setTitleLabel(_ label: UILabel)
}

extension CustomNavBarViewable where Self: UIViewController {
    
    func setupNavBar(height: CGFloat = 50.0, color: UIColor? = nil) {
        self.navigationController?.isNavigationBarHidden = true
        setupNavView(height: height)
        setupNavBarBackgroundView()
        navView.backgroundColor = color
        navBackgroundView.backgroundColor = color
    }
    
    func setTitleLabel(_ label: UILabel) {
        navView.addSubview(label)
        label.snp.makeConstraints { $0.center.equalTo(navView).offset(2) }
    }
    
    private func setupNavView(height: CGFloat) {
        view.addSubview(navView)
        navView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.height.equalTo(height)
            make.topEqualTo(view)
        }
    }
    
    private func setupNavBarBackgroundView() {
        view.insertSubview(navBackgroundView, belowSubview: navView)
        navBackgroundView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(view)
            make.bottom.equalTo(navView.snp.bottom)
        }
    }
    
}


