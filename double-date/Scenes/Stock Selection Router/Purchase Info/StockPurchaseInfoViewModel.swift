//
//  StockPurchaseInfoViewModel.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/9/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol StockPurchaseInfoViewModelDelegate: BackButtonNavigatable {
    func didSelectNumberOfShares(_ sharesCount: Double)
}

struct StockPurchaseInfoViewModel {
    
    //MARK: - Properties
    let disposeBag = DisposeBag()
    private let _stock: Variable<Stock>
    private let _portflioCashBalance = Variable<Double?>(nil)
    private let _funds = Variable<[Fund]>([])
    private let cache: Cache = Cache<Fund>(path: "funds")
    private let _sharesInputText = PublishSubject<String>()
    
    let activityIndicator = PublishSubject<Bool>()
    let errorTracker = PublishSubject<NetworkError>()
    weak var delegate: StockPurchaseInfoViewModelDelegate?
    
    init(stock: Stock) {
        self._stock = Variable(stock)
        cache.fetchObjects().asObservable()
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .filter { $0.count == 1 }
            .map { $0.first!.currentUserPortfolio.cashBalance }
            .bind(to: _portflioCashBalance)
            .disposed(by: disposeBag)
    }
    
    //MARK: - Outputs
    var stock: Driver<Stock> {
        return _stock.asDriver()
    }
    
    var totalPurchaseValue: Driver<Double> {
        return _sharesInputText.asObservable()
            .map { Double($0) }
            .map { ($0 ?? 0.0) * self._stock.value.latestPrice }
            .asDriver(onErrorJustReturn: 0.0)
    }
    
    var portfolioCashBalance: Driver<Double> {
        return _portflioCashBalance.asDriver()
            .filterNil()
    }
    
    var isValidPurchase: Driver<Bool> {
        return totalPurchaseValue
            .map { totalValue in
                if let singlePortCashBalance = self._portflioCashBalance.value {
                    return totalValue < singlePortCashBalance && totalValue > 0.0
                } else {
                    return totalValue > 0.0
                }
            }
    }
    
    var isLoading: Driver<Bool> {
        return activityIndicator.asDriver(onErrorJustReturn: false)
    }
    
    var error: Driver<NetworkError> {
        return errorTracker.asDriverOnErrorJustComplete()
    }
    
    //MARK: - Inputs
    func bindSharesText(_ observable: Observable<String>) {
        observable
            .bind(to: _sharesInputText)
            .disposed(by: disposeBag)
    }
    
    func bindContinueButton(_ observable: Observable<Void>) {
        observable
            .withLatestFrom(_sharesInputText.asObservable())
            .map { Double($0) }
            .filterNil()
            .subscribe(onNext: {
                self.delegate?.didSelectNumberOfShares($0)
            })
            .disposed(by: disposeBag)
    }
    
    func bindBackButton(_ observable: Observable<Void>) {
        observable
            .subscribe(onNext: {
                self.delegate?.didTapBackButton()
            })
            .disposed(by: disposeBag)
    }
    
}
