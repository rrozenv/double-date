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
    func didSelect(sharesCount: Double, limit: Double?)
}

struct StockPurchaseInfoViewModel {
    
    //MARK: - Properties
    let disposeBag = DisposeBag()
    private let _stock: Variable<Stock>
    private let _portflioCashBalance: Variable<Double>
    private let _funds = Variable<[Fund]>([])
    private let cache: Cache = Cache<Fund>(path: "funds")
    private let _sharesInputText = Variable<String>("")
    private let _limitInputText = Variable<String>("")
    private let _stopInputText = Variable<String>("")
    
    let activityIndicator = PublishSubject<Bool>()
    let errorTracker = PublishSubject<NetworkError>()
    weak var delegate: StockPurchaseInfoViewModelDelegate?
    
    init(stock: Stock, maxPurchaseValue: Double) {
        self._stock = Variable(stock)
        self._portflioCashBalance = Variable(maxPurchaseValue)
        //cache.fetchObjects().asObservable()
//            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
//            .map { $0.map { $0.currentUserPortfolio.cashBalance } }
//            .map { $0.min() }
//            .bind(to: _portflioCashBalance)
//            .disposed(by: disposeBag)
    }
    
    //MARK: - Outputs
    var stock: Driver<Stock> {
        return _stock.asDriver()
    }
    
    var totalPurchaseValue: Driver<Double> {
        return _sharesInputText.asObservable()
            .map { Double($0) }
            .map { ($0 ?? 0.0) * self._stock.value.quote.latestPrice }
            .asDriver(onErrorJustReturn: 0.0)
    }
    
    var portfolioCashBalance: Driver<String> {
        return _portflioCashBalance.asDriver()
            //.filterNil()
            .map { $0.asCurreny }
    }
    
    var isValidPurchase: Driver<Bool> {
        return totalPurchaseValue
            .map { totalValue in
                //if let singlePortCashBalance = self._portflioCashBalance.value {
                    return totalValue <= self._portflioCashBalance.value && totalValue > 0.0
                //} else {
//                    return totalValue > 0.0
//                }
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
    
    func bindLimitText(_ observable: Observable<String>) {
        observable
            .bind(to: _limitInputText)
            .disposed(by: disposeBag)
    }
    
    func bindContinueButton(_ observable: Observable<Void>) {
        observable
            .map { (shares: Double(self._sharesInputText.value),
                    limit: Double(self._limitInputText.value))
            }
            .filter { $0.shares != nil }
            .subscribe(onNext: {
                self.delegate?.didSelect(sharesCount: $0.shares!, limit: $0.limit)
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
