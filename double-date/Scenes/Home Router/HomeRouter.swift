//
//  HomeRouter.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/22/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

final class HomeRouter: Routable {
    
    enum Screen {
        case tabHome
        case createFund
    }
    
    //MARK: - Private Props
    let disposeBag = DisposeBag()
    
    //MARK: - Routable Props
    let navVc = UINavigationController()
    let screenOrder: [Screen] = [.tabHome, .createFund]
    var screenIndex = 0
    private var createFundRouter: CreateFundRouter?
    private var stockSelectionRouter: StockSelectionRouter?
    
    //MARK: - Public Props
    var newFund = Variable<Fund?>(nil)
    
    lazy var fundVc: FundListViewController = { [unowned self] in
        var fundVc = FundListViewController()
        var fundVm = FundListViewModel()
        fundVm.delegate = self
        fundVc.setViewModelBinding(model: fundVm)
        return fundVc
    }()
    
    lazy var marketVc: MarketViewController = { [unowned self] in
        var marketVc = MarketViewController()
        var marketVm = MarketViewModel()
        marketVm.delegate = self
        marketVc.setViewModelBinding(model: marketVm)
        return marketVc
    }()
    
    lazy var profileVc: ProfileViewController = { [unowned self] in
        var profileVc = ProfileViewController()
        var profileVm = ProfileViewModel()
        profileVm.delegate = self
        profileVc.setViewModelBinding(model: profileVm)
        return profileVc
    }()
    
    init() {
        self.navigateTo(screen: .tabHome)
        navVc.isNavigationBarHidden = true
    }
    
    deinit {
        print("HomeRouter deinit")
    }
    
    func navigateTo(screen: Screen) {
        switch screen {
        case .tabHome: toFundDetails()
        case .createFund: break
        }
    }
    
}

extension HomeRouter {
    
    private func toFundDetails() {
        let tabVc = TabPageViewController(viewControllers: [fundVc,
                                                            marketVc,
                                                            profileVc],
                                          tabView: TabBarView(bttnCount: 3))
        navVc.pushViewController(tabVc, animated: true)
    }
    
}

extension HomeRouter: FundListViewModelDelegate {

    func didTapCreateFund(_ vm: FundListViewModel) {
        createFundRouter = CreateFundRouter()
        
        createFundRouter!.newFund.asObservable()
            .filterNil()
            .bind(to: vm.bindNewFund)
        
        createFundRouter!.dismiss.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.createFundRouter = nil
            })
            .disposed(by: vm.disposeBag)
        
        navVc.present(createFundRouter!.navVc, animated: true, completion: nil)
    }
    
    func didSelectFund(_ fund: Fund) {
        var vc = FundInfoViewController()
        var vm = FundInfoViewModel(fund: fund)
        vm.delegate = self
        vc.setViewModelBinding(model: vm)
        
        var vc2 = ProfileViewController()
        var vm2 = ProfileViewModel()
        vm2.delegate = self
        vc2.setViewModelBinding(model: vm2)
        
        let tabVc = FundInfoTabViewController(viewControllers: [vc,
                                                    vc2],
                                  tabView: TabBarView(bttnCount: 2))
        navVc.pushViewController(tabVc, animated: true)
    }
    
}

extension HomeRouter: MarketViewModelDelegate {
    
    func didSelectStock(_ stock: Stock) {
        stockSelectionRouter = StockSelectionRouter(stock: stock)
        
        stockSelectionRouter!.newPosition.asObservable()
            .bind(to: profileVc.viewModel.bindNewPosition)
       
        stockSelectionRouter!.didDismiss.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.stockSelectionRouter = nil
            })
            .disposed(by: profileVc.viewModel.disposeBag)
        
        navVc.present(stockSelectionRouter!.navVc, animated: true, completion: nil)
    }
    
}

extension HomeRouter: FundInfoViewModelDelegate {
    
    func didTapBackButton() {
        navVc.popViewController(animated: true)
    }
    
}

extension HomeRouter: ProfileViewModelDelegate {
    
    func didTapLogoutButton() {
        NotificationCenter.default.post(name: .logout, object: nil)
    }
    
}
