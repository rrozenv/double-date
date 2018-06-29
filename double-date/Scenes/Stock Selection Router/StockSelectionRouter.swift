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
    var fundIds: [String]?
    
    init(stock: Stock?, posType: PositionType?, fundIds: [String]?) {
        self.stock = stock
        self.positionType = posType
        self.fundIds = fundIds
    }
    
    var isValid: Bool {
        return stock != nil
            && positionType != nil
            && fundIds != nil
    }
}

final class StockSelectionRouter: Routable {
    
    enum Screen {
        case stockDetail(Stock)
        case selectFunds
    }
    
    //MARK: - Private Props
    private let disposeBag = DisposeBag()
    private let fundService = FundService()
    private let positionInfo: Variable<PositionInfo>
    private let _funds = Variable<[Fund]>([])
    private let cache: Cache = Cache<Fund>(path: "funds")
    private let createPosition = PublishSubject<Void>()
    private let activityIndicator: ActivityIndicator
    
    //MARK: - Routable Props
    let navVc = UINavigationController()
    let screenOrder: [Screen]
    var screenIndex = 0
    
    var didDismiss = PublishSubject<Void>()
    
    deinit {
        print("StockSelectionRouter deinit")
    }
    
    init(stock: Stock) {
        let activityIndicator = ActivityIndicator()
        self.activityIndicator = activityIndicator
        self.screenOrder = [.stockDetail(stock), .selectFunds]
        self.positionInfo = Variable(PositionInfo(stock: stock, posType: nil, fundIds: nil))
        self.createPosition.asObservable()
            .withLatestFrom(positionInfo.asObservable())
            .filter { $0.isValid }
            .flatMapLatest { _ in
                self.fundService.getFunds()
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }
            .subscribe(onNext: { [weak self] _ in
                print("receieved funds!")
                self?.didTapBackButton()
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
        case .stockDetail(let stock): toStockDetail(stock)
        case .selectFunds: toSelectFund()
        }
    }
    
}

extension StockSelectionRouter {
    
    private func toStockDetail(_ stock: Stock) {
        var vc = StockDetailViewController()
        var vm = StockDetailViewModel(stock: stock)
        vm.delegate = self
        activityIndicator.asObservable()
            .bind(to: vm.activityIndicator)
            .disposed(by: vm.disposeBag)
        vc.setViewModelBinding(model: vm)
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
        print("did select \(type.rawValue)")
        let fundIds = _funds.value.map { $0._id }
        positionInfo.value.positionType = type
        switch _funds.value.count {
        case 0:
            print("You are not part of any games. You must create or join a game before you can add a stock to your portfolio.")
            let alertInfo = AlertViewController.AlertInfo.noFundsError
            let alertVc = AlertViewController(alertInfo: alertInfo, okAction: { [weak self] in
                self?.navVc.dismiss(animated: true, completion: nil)
            })
            self.displayAlert(vc: alertVc)
        case 1:
            print("Only part of 1 fund. Create Position")
            positionInfo.value.fundIds?.append(contentsOf: fundIds)
        default:
            print("Multiple funds. Display Select funds screen")
            navigateTo(screen: .selectFunds)
        }
    }
    
    func didTapBackButton() {
        self.navVc.dismiss(animated: true, completion: { [weak self] in
            self?.didDismiss.onNext(())
        })
    }
    
}

extension StockSelectionRouter: SelectFundViewModelDelegate {
    
    func didSelectFundIds(_ ids: [String]) {
        print("\(ids)")
        self.positionInfo.value.fundIds = ids
        createPosition.onNext(())
    }

}
