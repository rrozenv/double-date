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
    var stock: Stock?
    var positionType: PositionType?
    var fundIds = [String]()
    var sharesCount: Double = 0.0
    
    init(stock: Stock?, posType: PositionType?) {
        self.stock = stock
        self.positionType = posType
    }
    
    var isValid: Bool {
        return stock != nil
            && positionType != nil
            && fundIds.isNotEmpty
            && sharesCount > 0.0
    }
    
    var json: [String: Any] {
        return [
            "type": positionType!.rawValue,
            "ticker": stock!.symbol,
            "buyPrice": stock!.latestPrice,
            "currentPrice": stock!.latestPrice,
            "shares": 20,
            "fundIds": fundIds
        ]
    }
}

final class StockSelectionRouter: Routable {
    
    enum Screen {
        case stockDetail(Stock)
        case selectSharesCount(Stock)
        case selectFunds
    }
    
    //MARK: - Private Props
    private let disposeBag = DisposeBag()
    private let positionService = PositionService()
    private let positionInfo: Variable<PositionInfo>
    private let _funds = Variable<[Fund]>([])
    private let cache: Cache = Cache<Fund>(path: "funds")
    private let createPosition = PublishSubject<Void>()
    private let activityIndicator: ActivityIndicator
    private let errorTracker: ErrorTracker
    private let stock: Stock
    private var currentScreen: Screen
    
    //MARK: - Routable Props
    let navVc = UINavigationController()
    let screenOrder: [Screen]
    var screenIndex = 0
    
    var didDismiss = PublishSubject<Void>()
    var newPosition = PublishSubject<Position>()
    
    deinit {
        print("StockSelectionRouter deinit")
    }
    
    init(stock: Stock) {
        self.stock = stock
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        self.activityIndicator = activityIndicator
        self.errorTracker = errorTracker
        self.screenOrder = [.stockDetail(stock), .selectSharesCount(stock), .selectFunds]
        self.currentScreen = .stockDetail(stock)
        self.positionInfo = Variable(PositionInfo(stock: stock, posType: nil))
        self.createPosition.asObservable()
            .withLatestFrom(positionInfo.asObservable())
            .filter { $0.isValid }
            .flatMapLatest { [unowned self] in
                self.positionService.create(params: $0.json)
                    .trackNetworkError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }
            .subscribe(onNext: { [weak self] in
                self?.newPosition.onNext($0)
                //self?.didTapBackButton()
            })
            .disposed(by: disposeBag)
        
        cache.fetchObjects().asObservable()
            .bind(to: _funds)
            .disposed(by: disposeBag)
        
        self.navigateTo(screen: .stockDetail(stock))
        navVc.isNavigationBarHidden = true
    }
    
    func navigateTo(screen: Screen) {
        switch screen {
        case .stockDetail(let stock):
            toStockDetail(stock)
        case .selectSharesCount(let stock):
            toSelectSharesCount(stock)
        case .selectFunds:
            toSelectFund()
        }
    }
    
}

extension StockSelectionRouter {
    
    private func toStockDetail(_ stock: Stock) {
        var vc = StockDetailViewController()
        var vm = StockDetailViewModel(stock: stock)
        vm.delegate = self
        vc.setViewModelBinding(model: vm)
        navVc.pushViewController(vc, animated: true)
    }
    
    private func toSelectSharesCount(_ stock: Stock) {
        var vc = StockPurchaseInfoViewController()
        var vm = StockPurchaseInfoViewModel(stock: stock)
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
    
    private func toSelectFund() {
        var vc = SelectFundViewController()
        var vm = SelectFundViewModel()
        vm.delegate = self
        vc.setViewModelBinding(model: vm)
        vc.modalPresentationStyle = .overCurrentContext
        navVc.present(vc, animated: true, completion: nil)
    }
    
}

extension StockSelectionRouter: StockDetailViewModelDelegate {
    
    func didSelectPositionType(_ type: PositionType) {
        guard _funds.value.isNotEmpty else {
            let alertInfo = AlertViewController.AlertInfo.noFundsError
            let alertVc = AlertViewController(alertInfo: alertInfo, okAction: { [weak self] in
                self?.navVc.dismiss(animated: true, completion: nil)
            })
            self.displayAlert(vc: alertVc)
            return
        }
  
        positionInfo.value.positionType = type
        navigateTo(screen: .selectSharesCount(stock))
    }
    
    func didTapBackButton() {
        switch currentScreen {
        case .stockDetail(_):
            self.toPreviousScreen(completion: { [weak self] in
                self?.didDismiss.onNext(())
            })
        case .selectSharesCount(_):
            self.toPreviousScreen()
        case .selectFunds:
            break
        }
    }
    
}

extension StockSelectionRouter: StockPurchaseInfoViewModelDelegate {
    
    func didSelectNumberOfShares(_ sharesCount: Double) {
        positionInfo.value.sharesCount = sharesCount
        if _funds.value.count == 1 {
            let fundIds = _funds.value.map { $0._id }
            positionInfo.value.fundIds.append(contentsOf: fundIds)
            createPosition.onNext(())
        } else {
            navigateTo(screen: .selectFunds)
        }
    }
    
}

extension StockSelectionRouter: SelectFundViewModelDelegate {
    
    func didSelectFundIds(_ ids: [String]) {
        self.positionInfo.value.fundIds = ids
        self.navVc.dismiss(animated: true, completion: { [weak self] in
            self?.createPosition.onNext(())
        })
    }

}
