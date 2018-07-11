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

protocol StockPurchaseInfoViewModelDelegate: class {
    func didSelectNumberOfShares(_ sharesCount: Double)
    func didTapBackButton()
}

struct StockPurchaseInfoViewModel {
    
    //MARK: - Properties
    let disposeBag = DisposeBag()
    private let _stock: Variable<Stock>
    private let _sharesInputText = PublishSubject<String>()
    
    let activityIndicator = PublishSubject<Bool>()
    let errorTracker = PublishSubject<NetworkError>()
    weak var delegate: StockPurchaseInfoViewModelDelegate?
    
    init(stock: Stock) {
        self._stock = Variable(stock)
    }
    
    //MARK: - Outputs
    var stock: Driver<Stock> {
        return _stock.asDriver()
    }
    
    var totalPurchaseValue: Driver<Double> {
        return _sharesInputText.asObservable()
            .map { Double($0) }
            .filterNil()
            .map { $0 * self._stock.value.latestPrice }
            .asDriver(onErrorJustReturn: 0.0)
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
