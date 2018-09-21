//
//  CustomNavigationController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 9/20/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

//protocol TabBarViewable: class {
//    var buttons: [UIButton] { get }
//    func adjustButtonStyle(selected tag: Int)
//}

final class CustomNavigationController: UIViewController {
    
    private(set) var navBarView: UIView!
    let navVc = UINavigationController()
    
    required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder)! }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(navView: UIView) {
        super.init(nibName: nil, bundle: nil)
        self.navBarView = navView
    }
    
    deinit { print("CustomNavigationController deinit") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navVc.navigationBar.isHidden = true
        view.backgroundColor = UIColor.white
        setupNavBarView()
        setupNavVc()
    }
    
}

extension CustomNavigationController {
    
    private func setupNavBarView() {
        view.addSubview(navBarView)
        navBarView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(view)
            make.height.equalTo(50)
        }
    }
    
    private func setupNavVc() {
        self.addChild(navVc, frame: .zero, animated: false, belowView: navBarView)
        navVc.view.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(view)
            make.top.equalTo(navBarView.snp.bottom)
        }
    }
}
