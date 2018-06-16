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
    func setupNavBar()
}

extension CustomNavBarViewable where Self: UIViewController {
    
    func setupNavBar() {
        self.navigationController?.isNavigationBarHidden = true
        setupNavView()
        setupNavBarBackgroundView()
    }
    
    private func setupNavView() {
        view.addSubview(navView)
        navView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.height.equalTo(60)
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


