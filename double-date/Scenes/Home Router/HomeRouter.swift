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
        case stockSearch
    }
    
    //MARK: - Private Props
    let disposeBag = DisposeBag()
    
    //MARK: - Routable Props
    let navVc = UINavigationController()
    let screenOrder: [Screen] = [.tabHome, .createFund]
    var screenIndex = 0
    private var createFundRouter: CreateFundRouter?
    private var stockSelectionRouter: StockSelectionRouter?
    
    lazy var fundVc: FundListViewController = { [unowned self] in
        var fundVc = FundListViewController()
        var fundVm = FundListViewModel()
        fundVm.delegate = self
        fundVc.setViewModelBinding(model: fundVm)
        return fundVc
    }()
    
    lazy var marketVc: MarketViewController = { [unowned self] in
        var marketVc = MarketViewController(displayBackButton: false)
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
    
    deinit { print("HomeRouter deinit") }
    
    func navigateTo(screen: Screen) {
        switch screen {
        case .tabHome: toFundDetails()
        case .stockSearch: toStockSearch()
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
                                          tabView: TabBarView(icons: [#imageLiteral(resourceName: "IC_Dashboard"), #imageLiteral(resourceName: "IC_Market"), #imageLiteral(resourceName: "IC_Invitations"), #imageLiteral(resourceName: "IC_Profile")]))
        navVc.pushViewController(tabVc, animated: true)
    }
    
    private func toStockSearch() {
        var marketVc = MarketViewController(displayBackButton: true)
        var marketVm = MarketViewModel()
        marketVm.delegate = self
        marketVc.setViewModelBinding(model: marketVm)
        navVc.pushViewController(marketVc, animated: true)
    }
    
}

extension HomeRouter: FundListViewModelDelegate {

    func didTapCreateFund(_ vm: FundListViewModel) {
        createFundRouter = CreateFundRouter()
        
        let newFund$ = createFundRouter!.newFund.asObservable().filterNil()
        vm.bindNewFund(newFund$, disposeBag: nil)
        
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
        let positionsListVm = PositionsListViewModel(fund: fund)
        positionsListVc.setViewModelBinding(model: positionsListVm)
        
        let tabAppearence = TabAppearence(type: .underline(Palette.lightBlue.color),
                                          itemTitles: ["POSITIONS", "LEADERBOARD"],
                                          height: 56.0,
                                          selectedBkgColor: .white,
                                          selectedTitleColor: Palette.lightBlue.color,
                                          notSelectedBkgColor: .white,
                                          notSelectedTitleColor: Palette.lightBlue.color)
        
        let tabVc = FundInfoTabViewController(viewControllers: [positionsListVc,
                                                                portfolioListVc],
                                              tabView: TabOptionsView(appearence: tabAppearence),
                                              fund: fund)
        
        let newFund$ = positionsListVm._fund.asObservable().share()
        newFund$.bind(to: tabVc._fund).disposed(by: tabVc.disposeBag)
        fundVc.viewModel.bindNewFund(newFund$, disposeBag: tabVc.disposeBag)
        
        positionsListVc._scrollViewDidScroll
            .bind(to: tabVc.scrollViewDidScroll)
            .disposed(by: tabVc.disposeBag)
        
        tabVc.delegate = self
        navVc.pushViewController(tabVc, animated: true)
    }
    
}

extension HomeRouter: MarketViewModelDelegate {
   
    func didSelectStock(_ stock: Stock) {
        stockSelectionRouter = StockSelectionRouter(stock: stock)
        
//        stockSelectionRouter!.newPosition.asObservable()
//            .bind(to: profileVc.viewModel.bindNewPosition)
        
        stockSelectionRouter!.newPosition.asObservable()
            .bind(to: fundVc.viewModel.bindNewPosition)
        
        stockSelectionRouter!.newPosition.asObservable()
            .subscribe(onNext: { _ in
                NotificationCenter.default.post(name: .newPositionAdded, object: nil)
            })
            .disposed(by: stockSelectionRouter!.disposeBag)
       
        stockSelectionRouter!.didDismiss.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.stockSelectionRouter = nil
            })
            .disposed(by: profileVc.viewModel.disposeBag)
        
        navVc.present(stockSelectionRouter!.navVc, animated: true, completion: nil)
    }
    
}

extension HomeRouter: FundInfoTabViewControllerDelegate {
    
    func didTapSearchStockButton() {
        navigateTo(screen: .stockSearch)
    }
    
    func didTapBackButton() {
        navVc.popViewController(animated: true)
    }
    
}

extension HomeRouter: ProfileViewModelDelegate {
    
    func didTapLogoutButton() {
        NotificationCenter.default.post(name: .logout, object: nil)
    }
    
}
