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

struct MarketViewModel {
    
    let disposeBag = DisposeBag()
    
    //MARK: - Properties
    private let stockService = StockService()
    private let errorTracker: ErrorTracker
    private let _stocks = Variable<[Stock]>([])
    
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
    
}
