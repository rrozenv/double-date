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
    
    lazy var fundVc: FundListViewController = {
        var fundVc = FundListViewController()
        var fundVm = FundListViewModel()
        fundVm.delegate = self
        fundVc.setViewModelBinding(model: fundVm)
        return fundVc
    }()
    
    lazy var marketVc: MarketViewController = {
        var marketVc = MarketViewController()
        var marketVm = MarketViewModel()
        marketVm.delegate = self
        marketVc.setViewModelBinding(model: marketVm)
        return marketVc
    }()
    
    lazy var profileVc: ProfileViewController = {
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
                                          tabView: TabBarView())
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
            .disposed(by: disposeBag)
        
        navVc.present(createFundRouter!.navVc, animated: true, completion: nil)
    }
    
    func didSelectFund(_ fund: Fund) {
        
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
            .disposed(by: disposeBag)
        
        navVc.present(stockSelectionRouter!.navVc, animated: true, completion: nil)
    }
    
}

extension HomeRouter: ProfileViewModelDelegate {
    
    func didTapLogoutButton() {
        NotificationCenter.default.post(name: .logout, object: nil)
    }
    
}
