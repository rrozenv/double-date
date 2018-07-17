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
    
    lazy var invitationsVc: InvitationsListViewController = { [unowned self] in
        var invitesVc = InvitationsListViewController()
        var invitesVm = InvitationsListViewModel()
        invitesVc.setViewModelBinding(model: invitesVm)
        return invitesVc
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
                                                            invitationsVc,
                                                            profileVc],
                                          tabView: TabBarView(bttnCount: 4))
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
        var portfolioListVc = PortfolioListViewController()
        let portfolioListVm = PortfolioListViewModel(fund: fund)
        portfolioListVc.setViewModelBinding(model: portfolioListVm)
        
        var positionsListVc = PositionsListViewController()
        let positionsListVm = PositionsListViewModel(positions: fund.currentUserPortfolio.positions)
        positionsListVc.setViewModelBinding(model: positionsListVm)
        
        let tabAppearence = TabAppearence(type: .underline(.blue),
                                          itemTitles: ["Positions", "Leaderboard"],
                                          height: 56.0,
                                          selectedBkgColor: .white,
                                          selectedTitleColor: .blue,
                                          notSelectedBkgColor: .white,
                                          notSelectedTitleColor: .gray)
        
        let tabVc = FundInfoTabViewController(viewControllers: [positionsListVc,
                                                                portfolioListVc],
                                              tabView: TabOptionsView(appearence: tabAppearence),
                                              fund: fund)
        tabVc.delegate = self
        navVc.pushViewController(tabVc, animated: true)
    }
    
}

extension HomeRouter: MarketViewModelDelegate {
   
    func didSelectStock(_ stock: Stock) {
        stockSelectionRouter = StockSelectionRouter(stock: stock)
        
        stockSelectionRouter!.newPosition.asObservable()
            .bind(to: profileVc.viewModel.bindNewPosition)
        
        stockSelectionRouter!.newPosition.asObservable()
            .bind(to: fundVc.viewModel.bindNewPosition)
       
        stockSelectionRouter!.didDismiss.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.stockSelectionRouter = nil
            })
            .disposed(by: profileVc.viewModel.disposeBag)
        
        navVc.present(stockSelectionRouter!.navVc, animated: true, completion: nil)
    }
    
}

extension HomeRouter: FundInfoTabViewControllerDelegate {
    
    func didTapBackButton() {
        navVc.popViewController(animated: true)
    }
    
}

extension HomeRouter: ProfileViewModelDelegate {
    
    func didTapLogoutButton() {
        NotificationCenter.default.post(name: .logout, object: nil)
    }
    
}
