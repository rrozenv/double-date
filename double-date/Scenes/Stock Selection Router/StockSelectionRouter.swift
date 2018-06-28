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
    private let positionInfo: Variable<PositionInfo>
    
    //MARK: - Routable Props
    let navVc = UINavigationController()
    let screenOrder: [Screen]
    var screenIndex = 0
    
    var dismiss = PublishSubject<Void>()
    
    deinit {
        print("StockSelectionRouter deinit")
    }
    
    init(stock: Stock) {
        self.screenOrder = [.stockDetail(stock), .selectFunds]
        self.positionInfo = Variable(PositionInfo())
        self.positionInfo.asObservable()
            .filter { $0.isValid }
            .subscribe(onNext: { [weak self] in
                print("sending network request with \($0)")
                self?.navVc.dismiss(animated: true, completion: {
                    self?.dismiss.onNext(())
                })
            })
            .disposed(by: disposeBag)
        
        self.navigateTo(screen: .stockDetail(stock))
        navVc.isNavigationBarHidden = true
    }
    
    func navigateTo(screen: Screen) {
        switch screen {
        case .stockDetail(let stock): toStockDetail(stock)
        case .selectFunds: break
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
    
}

extension StockSelectionRouter: StockDetailViewModelDelegate {
    
    func didSelectPositionType(_ type: PositionType) {
        print("did select \(type.rawValue)")
    }
    
    func didTapBackButton() {
        self.navVc.dismiss(animated: true, completion: { [weak self] in
            self?.dismiss.onNext(())
        })
    }
    
}
