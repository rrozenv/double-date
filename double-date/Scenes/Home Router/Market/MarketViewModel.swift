//
//  MarketViewModel.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/26/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol MarketViewModelDelegate: class {
    func didSelectStock(_ stock: Stock)
}

struct MarketViewModel {
    
    let disposeBag = DisposeBag()
    
    //MARK: - Properties
    private let stockService = StockService()
    private let errorTracker: ErrorTracker
    private let _stocks = Variable<[Stock]>([])
    weak var delegate: MarketViewModelDelegate?
    
    //MARK: - Init
    init(errorTracker: ErrorTracker = ErrorTracker()) {
        self.errorTracker = errorTracker
    }
    
    //MARK: - Outputs
    var stocks: Driver<[Stock]> {
        return _stocks.asDriver()
    }
    
    var error: Driver<NetworkError> {
        return errorTracker.asDriver()
    }
    
    //MARK: - Inputs
    func bindFetchStocks(_ observable: Observable<Void>) {
        observable
            .flatMapLatest {
                self.stockService.getStocks()
                    .trackNetworkError(self.errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .bind(to: _stocks)
            .disposed(by: disposeBag)
    }
    
    func bindSelectedStock(_ observable: Observable<Stock>) {
        observable
            .subscribe(onNext: {
                self.delegate?.didSelectStock($0)
            })
            .disposed(by: disposeBag)
    }

}
