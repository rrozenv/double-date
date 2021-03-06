//
//  StockSelectionRouter.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/27/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift

final class PositionInfo {
    var stock: Stock
    var positionType: PositionType
    var funds = [Fund]()
    var sharesCount: Double = 0.0
    var limitPrice: Double?
    
    init(stock: Stock, posType: PositionType) {
        self.stock = stock
        self.positionType = posType
    }
    
    var isValid: Bool {
        return funds.isNotEmpty
            && sharesCount > 0.0
    }
    
    var json: [String: Any] {
        return [
            "type": positionType.rawValue,
            "ticker": stock.quote.symbol,
            "buyPrice": isLimitPriceValid ? limitPrice! : stock.quote.latestPrice,
            "currentPrice": stock.quote.latestPrice,
            "shares": sharesCount,
            "fundIds": funds.map { $0._id },
            "orderType": isLimitPriceValid ? "openLimit" : "market"
        ]
    }
    
    private var isLimitPriceValid: Bool {
        guard let limitPrice = limitPrice else { return false }
        return limitPrice < stock.quote.latestPrice
    }
}

final class StockSelectionRouter: Routable {
    
    //MARK: - Navigatable Screens
    enum Screen: Int {
        case stockDetail
        case selectFunds
        case selectSharesCount
    }
    
    //MARK: - Private Props
    let disposeBag = DisposeBag()
    private let positionService = PositionService()
    private let positionInfo: Variable<PositionInfo>
    private let _funds = Variable<[Fund]>([])
    private let cache: Cache = Cache<Fund>(path: "funds")
    private let createPosition = PublishSubject<Void>()
    private let activityIndicator: ActivityIndicator
    private let errorTracker: ErrorTracker
    private let stock: Stock
    
    //MARK: - Routable Props
    let navVc = UINavigationController()
    var screenOrder: [Screen]
    var screenIndex = 0
    
    //MARK: - Outputs
    var didDismiss = PublishSubject<Void>()
    var newPosition = PublishSubject<Position>()
    
    deinit {
        print("StockSelectionRouter deinit")
    }
    
    init(stock: Stock) {
        self.stock = stock
        self.activityIndicator = ActivityIndicator()
        self.errorTracker = ErrorTracker()
        self.screenOrder = [.stockDetail, .selectFunds, .selectSharesCount]
        self.positionInfo = Variable(PositionInfo(stock: stock, posType: .buy))
        self.cache.fetchObjects().asObservable()
            .bind(to: _funds)
            .disposed(by: disposeBag)
        self.toStockDetail(stock)
        self.navVc.isNavigationBarHidden = true
        self.setupCreatePositionAction()
    }
    
    private func setupCreatePositionAction() {
        self.createPosition.asObservable()
            .withLatestFrom(positionInfo.asObservable())
            .filter { $0.isValid }
            .flatMapLatest { [unowned self] in
                self.positionService.create(params: $0.json)
                    .trackNetworkError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .asDriverOnErrorJustComplete()
            }
            .subscribe(onNext: { [weak self] in
                self?.newPosition.onNext($0)
                self?.displayPositionConfirmationAlert(postion: $0)
            })
            .disposed(by: disposeBag)
    }
    
}

//MARK: - Routes
extension StockSelectionRouter {
    
    func navigateTo(screen: Screen) {
        switch screen {
        case .stockDetail:
            toStockDetail(stock)
        case .selectFunds:
            toSelectFunds()
        case .selectSharesCount:
            toSelectSharesCount(stock)
        }
        screenIndex += 1
    }
    
    private func toStockDetail(_ stock: Stock) {
        var vc = StockDetailViewController()
        var vm = StockDetailViewModel(stock: stock)
        vm.delegate = self
        vc.setViewModelBinding(model: vm)
        navVc.pushViewController(vc, animated: true)
    }
    
    private func toSelectSharesCount(_ stock: Stock) {
        let maxPurchaseValue = self.positionInfo.value.funds.map { $0.currentUserPortfolio.cashBalance }.min() ?? 0.0
        var vc = StockPurchaseInfoViewController()
        var vm = StockPurchaseInfoViewModel(stock: stock, maxPurchaseValue: maxPurchaseValue)
        vm.delegate = self
        vc.setViewModelBinding(model: vm)
        activityIndicator.asObservable()
            .bind(to: vm.activityIndicator)
            .disposed(by: vm.disposeBag)
        errorTracker.asObservable()
            .bind(to: vm.errorTracker)
            .disposed(by: vm.disposeBag)
        navVc.pushViewController(vc, animated: true)
    }
    
    private func toSelectFunds() {
        var vc = SelectFundViewController()
        var vm = SelectFundViewModel(funds: _funds.value.filter { $0.status == .open },
                                     stock: stock)
        vm.delegate = self
        vc.setViewModelBinding(model: vm)
        navVc.pushViewController(vc, animated: true)
    }
    
}

//MARK: - Action Delegates
extension StockSelectionRouter: StockDetailViewModelDelegate,
                                StockPurchaseInfoViewModelDelegate,
                                SelectFundViewModelDelegate {
    
    //MARK: - Position Type Selected
    func didSelectPositionType(_ type: PositionType) {
        let openFunds = _funds.value.filter { $0.status == .open }
        guard openFunds.count > 0 else {
            self.displayNoFundsError()
            return
        }
        positionInfo.value.positionType = type
        if openFunds.count == 1 {
            self.positionInfo.value.funds = _funds.value
            self.screenOrder = [.stockDetail, .selectSharesCount]
            self.navigateTo(screen: .selectSharesCount)
        } else {
            self.navigateTo(screen: .selectFunds)
        }
    }
    
    //MARK: - Shares Selected
     func didSelect(sharesCount: Double, limit: Double?) {
        positionInfo.value.sharesCount = sharesCount
        positionInfo.value.limitPrice = limit
        createPosition.onNext(())
    }
    
    //MARK: - Funds Selected
    func didSelectFunds(_ funds: [Fund]) {
        self.positionInfo.value.funds = funds
        self.navigateTo(screen: .selectSharesCount)
    }
    
    //MARK: - Back Button Selected
    func didTapBackButton() {
        guard let currentScreen = Screen(rawValue: screenIndex) else { return }
        switch currentScreen {
        case .stockDetail:
            self.toPreviousScreen(completion: { [weak self] in
                self?.didDismiss.onNext(())
            })
        case .selectFunds, .selectSharesCount:
            self.toPreviousScreen()
        }
    }
    
}

extension StockSelectionRouter {
    
    private func displayPositionConfirmationAlert(postion: Position) {
        let alertInfo = AlertViewController.AlertInfo.newPositionAlert(position: postion)
        let alertVc = AlertViewController(alertInfo: alertInfo, okAction: { [weak self] in
            self?.navVc.dismiss(animated: true, completion: { self?.didDismiss.onNext(()) })
        })
        self.displayAlert(vc: alertVc)
    }
    
    private func displayNoFundsError() {
        let alertInfo = AlertViewController.AlertInfo.noFundsError
        let alertVc = AlertViewController(alertInfo: alertInfo, okAction: { [weak self] in
            self?.navVc.dismiss(animated: true, completion: nil)
        })
        self.displayAlert(vc: alertVc)
    }
    
}

