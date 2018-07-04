//
//  FundInfoTabViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/3/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

final class FundInfoTabViewController: UIViewController, CustomNavBarViewable {
    
    private var dataSource: TabControllerDataSource!
    private let userService = UserService()
    private let errorTracker = ErrorTracker()
    private var tabView: (UIView & TabBarViewable)!
    private let disposeBag = DisposeBag()
    private var actingVc: UIViewController?
    var navView: BackButtonNavView = BackButtonNavView.blackArrow
    var navBackgroundView: UIView = UIView()
    
    required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder)! }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(viewControllers: [UIViewController], tabView: UIView & TabBarViewable) {
        super.init(nibName: nil, bundle: nil)
        self.tabView = tabView
        self.dataSource = TabControllerDataSource(viewControllers: viewControllers)
    }
    
    deinit { print("FundInfoTabViewController deinit") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        navView.containerView.backgroundColor = Palette.lightGrey.color
        navBackgroundView.backgroundColor = Palette.lightGrey.color
        view.backgroundColor = UIColor.white
        self.actingVc = dataSource.controllerFor(index: 0)!
        self.transiton(to: actingVc!)
        setupTabOptionsView()
        setupTabButtonBindings()
    }
    
    func setupTabButtonBindings() {
        tabView.buttons.forEach { button in
            button.rx.tap.asObservable().map { button.tag }
                .subscribe(onNext: { [unowned self] in
                    guard let vc = self.dataSource.controllerFor(index: $0) else { fatalError() }
                    self.transiton(to: vc)
                })
                .disposed(by: disposeBag)
        }
    }
    
}

extension FundInfoTabViewController {
    
    private func setupTabOptionsView() {
        view.addSubview(tabView)
        tabView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(navView.snp.bottom)
        }
    }
    
    private func transiton(to vc: UIViewController) {
        if actingVc != nil { self.removeChild(actingVc!, completion: nil) }
        self.actingVc = vc
        self.addChild(self.actingVc!, frame: nil, animated: true, belowView: tabView)
        
        actingVc!.view.snp.makeConstraints { (make) in
            make.bottom.left.right.equalTo(view)
            make.top.equalTo(view).offset(120)
        }
    }
    
}
