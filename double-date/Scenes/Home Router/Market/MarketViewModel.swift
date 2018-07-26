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
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    private let _stocks = Variable<[StockSummary]>([])
    private let _popularStocks = Variable<[StockSummary]>([])
    weak var delegate: MarketViewModelDelegate?
    
    //MARK: - Outputs
    var stocks: Driver<[StockSummary]> {
        return Driver.merge(_popularStocks.asDriver(), _stocks.asDriver())
    }
    
    var displayEmptyView: Driver<Bool> {
        return stocks.asObservable()
            .map { $0.isNotEmpty }
            .asDriver(onErrorJustReturn: true)
    }
 
    var error: Driver<NetworkError> {
        return errorTracker.asDriver()
    }
    
    var isLoading: Driver<Bool> {
        return activityIndicator.asDriver(onErrorJustReturn: false)
    }
    
    //MARK: - Inputs
    func bindFetchStocks(_ observable: Observable<Void>) {
        observable
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInitiated))
            .flatMapLatest {
                self.stockService.getPopularStocks()
                    .trackNetworkError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .asDriverOnErrorJustComplete()
            }
            .bind(to: _popularStocks)
            .disposed(by: disposeBag)
    }
    
    func bindSearchText(_ observable: Observable<String>) {
        observable
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInitiated))
            .map { text -> Observable<[StockSummary]> in
                if text.isEmpty || text == "" {
                   return self._popularStocks.asObservable()
                } else {
                    return self.stockService.getStockFor(query: text)
                        .trackNetworkError(self.errorTracker)
                        .trackActivity(self.activityIndicator)
                }
            }
            .switchLatest()
            .bind(to: _stocks)
            .disposed(by: disposeBag)
    }
    
    func bindClearSearch(_ observable: Observable<Void>) {
        observable
            .subscribe(onNext: {
                self._stocks.value = self._popularStocks.value
            })
            .disposed(by: disposeBag)
    }
    
    func bindSelectedStock(_ observable: Observable<Stock>) {
        observable
            .subscribe(onNext: {
                self.delegate?.didSelectStock($0)
            })
            .disposed(by: disposeBag)
    }
    
    func bindSelectedStockSummary(_ observable: Observable<StockSummary>) {
        observable
            .flatMapLatest {
                self.stockService.getDetailsFor(stockSummary: $0)
                    .trackNetworkError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                self.delegate?.didSelectStock($0)
            })
            .disposed(by: disposeBag)
    }

}
