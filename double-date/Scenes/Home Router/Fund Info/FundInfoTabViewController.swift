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
    func didTapSearchStockButton()
}

final class FundInfoTabViewController: UIViewController, CustomNavBarViewable {
    
    let disposeBag = DisposeBag()
    private var dataSource: TabControllerDataSource!
    private let userService = UserService()
    private let errorTracker = ErrorTracker()
    private var actingVc: UIViewController?
    var _fund: Variable<Fund>!
    
    private var tabView: (UIView & TabBarViewable)!
    private var headerView: FundDetailsHeaderView!
    private var gameNameLabel: UILabel!
    private var daysLeftLabel: UILabel!
    private var searchButton: UIButton!
    
    weak var delegate: FundInfoTabViewControllerDelegate?
    var navView: BackButtonNavView = BackButtonNavView.blackArrow
    var navBackgroundView: UIView = UIView()
    
    var scrollViewDidScroll = PublishSubject<UIScrollView>()
    
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
        navView.backgroundColor = Palette.aqua.color
        navBackgroundView.backgroundColor = Palette.aqua.color
        view.backgroundColor = UIColor.white
        setupHeaderView()
        setupTabOptionsView()
        setupNavLabels()
        setupStockSearchButton()
        self.actingVc = dataSource.controllerFor(index: 0)!
        self.transiton(to: actingVc!)
        setupTabButtonBindings()
    }
    
    func setupTabButtonBindings() {
        _fund.asObservable()
            .subscribe(onNext: { [unowned self] in
                self.headerView.populateInfoWith(netEquity: "\($0.currentUserPortfolio.netEquity.rounded().asCurreny)", returnPercentage: "\($0.currentUserPortfolio.portfolioROI.asPercentage)")
                self.gameNameLabel.text = $0.name
                self.daysLeftLabel.text = "\($0.daysLeft) days left"
            })
            .disposed(by: disposeBag)
        
        tabView.buttons.forEach { button in
            button.rx.tap.asObservable().map { button.tag }
                .subscribe(onNext: { [unowned self] in
                    guard let vc = self.dataSource.controllerFor(index: $0) else { fatalError() }
                    self.tabView.adjustButtonStyle(selected: $0)
                    self.transiton(to: vc)
                })
                .disposed(by: disposeBag)
        }
        
        navView.backButton.rx.tap.asObservable()
            .subscribe(onNext: { [unowned self] in
                self.delegate?.didTapBackButton()
            })
            .disposed(by: disposeBag)
        
        searchButton.rx.tap.asObservable()
            .subscribe(onNext: { [unowned self] in
                self.delegate?.didTapSearchStockButton()
            })
            .disposed(by: disposeBag)
        
        // Need to adjust child vc height as table is scrolled
        scrollViewDidScroll.asObservable()
            .subscribe()
            .disposed(by: disposeBag)
    }
    
}

extension FundInfoTabViewController {
    
    private func setupNavLabels() {
        gameNameLabel = UILabel().rxStyle(font: FontBook.AvenirHeavy.of(size: 13), color: Palette.darkNavy.color, alignment: .center)
        daysLeftLabel = UILabel().rxStyle(font: FontBook.AvenirMedium.of(size: 11), color: Palette.darkNavy.color, alignment: .center)
        
        let sv = UIStackView(arrangedSubviews: [gameNameLabel, daysLeftLabel])
        sv.axis = .vertical
        sv.spacing = 1.0
        
        view.addSubview(sv)
        sv.snp.makeConstraints { (make) in
            make.center.equalTo(navView)
        }
    }
    
    private func setupHeaderView() {
        headerView = FundDetailsHeaderView()
        
        view.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(navView.snp.bottom)
        }
    }
    
    private func setupTabOptionsView() {
        tabView.dropShadow()
        view.addSubview(tabView)
        tabView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(headerView.snp.bottom)
        }
    }
    
    private func setupStockSearchButton() {
        searchButton = UIButton().rxStyle(title: "Search", font: FontBook.AvenirHeavy.of(size: 12), backColor: .clear, titleColor: .white)
        
        navView.addSubview(searchButton)
        searchButton.snp.makeConstraints { (make) in
            make.right.equalTo(navView).offset(-20)
            make.centerY.equalTo(navView)
        }
    }
    
    private func transiton(to vc: UIViewController) {
        if actingVc != nil { self.removeChild(actingVc!, completion: nil) }
        self.actingVc = vc
        self.addChild(self.actingVc!, frame: nil, animated: true, belowView: tabView)
        
        actingVc!.view.snp.makeConstraints { (make) in
            make.bottom.left.right.equalTo(view)
            make.top.equalTo(tabView.snp.bottom)
        }
    }
    
}

