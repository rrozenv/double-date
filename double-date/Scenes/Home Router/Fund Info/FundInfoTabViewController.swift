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

protocol FundInfoTabViewControllerDelegate: class {
    func didTapBackButton()
}

final class FundInfoTabViewController: UIViewController, CustomNavBarViewable {
    
    private let disposeBag = DisposeBag()
    private var dataSource: TabControllerDataSource!
    private let userService = UserService()
    private let errorTracker = ErrorTracker()
    private var actingVc: UIViewController?
    private var _fund: Variable<Fund>!
    
    private var tabView: (UIView & TabBarViewable)!
    private var headerView: FundInfoHeaderView!
    
    weak var delegate: FundInfoTabViewControllerDelegate?
    var navView: BackButtonNavView = BackButtonNavView.blackArrow
    var navBackgroundView: UIView = UIView()
    
    required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder)! }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(viewControllers: [UIViewController], tabView: UIView & TabBarViewable, fund: Fund) {
        super.init(nibName: nil, bundle: nil)
        self.tabView = tabView
        self.dataSource = TabControllerDataSource(viewControllers: viewControllers)
        self._fund = Variable(fund)
    }
    
    deinit { print("FundInfoTabViewController deinit") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
//        navView.containerView.backgroundColor = Palette.lightGrey.color
//        navBackgroundView.backgroundColor = Palette.lightGrey.color
        view.backgroundColor = UIColor.white
        self.actingVc = dataSource.controllerFor(index: 0)!
        self.transiton(to: actingVc!)
        setupHeaderView()
        setupTabOptionsView()
        setupTabButtonBindings()
    }
    
    func setupTabButtonBindings() {
        _fund.asObservable()
            .subscribe(onNext: { [unowned self] in
                self.headerView
                    .populateInfoWith(titleText: "\($0.currentUserPortfolio.cashBalance.asCurreny)",
                                      subTitleText: "\($0.currentUserPortfolio.portfolioROI)%")
            })
            .disposed(by: disposeBag)
        
        tabView.buttons.forEach { button in
            button.rx.tap.asObservable().map { button.tag }
                .subscribe(onNext: { [unowned self] in
                    guard let vc = self.dataSource.controllerFor(index: $0) else { fatalError() }
                    self.transiton(to: vc)
                })
                .disposed(by: disposeBag)
        }
        
        navView.backButton.rx.tap.asObservable()
            .subscribe(onNext: { [unowned self] in
                self.delegate?.didTapBackButton()
            })
            .disposed(by: disposeBag)
    }
    
}

extension FundInfoTabViewController {
    
    private func setupHeaderView() {
        headerView = FundInfoHeaderView()
        
        view.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(navView.snp.bottom)
            make.height.equalTo(160)
        }
    }
    
    private func setupTabOptionsView() {
        view.addSubview(tabView)
        tabView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(headerView.snp.bottom)
        }
    }
    
    private func transiton(to vc: UIViewController) {
        if actingVc != nil { self.removeChild(actingVc!, completion: nil) }
        self.actingVc = vc
        self.addChild(self.actingVc!, frame: nil, animated: true, belowView: tabView)
        
        actingVc!.view.snp.makeConstraints { (make) in
            make.bottom.left.right.equalTo(view)
            make.top.equalTo(view).offset(120 + 160)
        }
    }
    
}
