//
//  FundListViewModel.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/22/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol FundListViewModelDelegate: class {
    func didTapCreateFund(_ vm: FundListViewModel)
    func didSelectFund(_ fund: Fund)
}

struct FundListViewModel {
    
    let disposeBag = DisposeBag()
    
    //MARK: - Properties
    private let fundService = FundService()
    private let posService = PositionService()
    private let stockService = StockService()
    private let errorTracker: ErrorTracker
    private let _funds = Variable<[Fund]>([])
    weak var delegate: FundListViewModelDelegate?
    
    //MARK: - Init
    init(errorTracker: ErrorTracker = ErrorTracker()) {
        self.errorTracker = errorTracker
    }
    
    //MARK: - Outputs
    var sections: Observable<[FundsListMultipleSectionViewModel]> {
        return _funds.asObservable()
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInitiated))
            .map { self.createSectionsFor(funds: $0) }
    }

    var error: Driver<NetworkError> {
        return errorTracker.asDriver()
    }
    
    //MARK: - Inputs
    func bindFetchFunds(_ observable: Observable<Void>) {
        observable
            .flatMapLatest {
                self.fundService.getFunds()
                    .trackNetworkError(self.errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .bind(to: _funds)
            .disposed(by: disposeBag)
    }
    
    func bindSelectedFund(_ observable: Observable<Fund>) {
        observable
            .subscribe(onNext: {
                self.delegate?.didSelectFund($0)
            })
            .disposed(by: disposeBag)
    }
    
    func bindCreateFund(_ observable: Observable<Void>) {
        observable
            .subscribe(onNext: {
                self.delegate?.didTapCreateFund(self)
            })
            .disposed(by: disposeBag)
    }
    
    func bindNewFund(_ observable: Observable<Fund>, disposeBag: DisposeBag?) {
        observable
            .subscribe(onNext: { fund in
                guard let index = self._funds.value.index(where: { $0._id == fund._id }) else {
                    self._funds.value.insert(fund, at: 0)
                    return
                }
                self._funds.value[index] = fund
            })
            .disposed(by: disposeBag ?? self.disposeBag)
    }
    
    func bindNewPosition(_ observable: Observable<Position>) {
        observable
            .subscribe(onNext: { position in
                position.fundIds.forEach({ (fundId) in
                    if let index = self._funds.value.index(where: { $0._id == fundId }) {
                        self._funds.value[index].currentUserPortfolio.positions.insert(position, at: 0)
                        if !position.isPendingBuy {
                          self._funds.value[index].currentUserPortfolio.cashBalance -= position.shares * position.buyPrice
                        }
                    }
                })
            })
            .disposed(by: disposeBag)
    }
    
}

extension FundListViewModel {
    
    private func createSectionsFor(funds: [Fund]) -> [FundsListMultipleSectionViewModel] {
        var sections = [FundsListMultipleSectionViewModel]()
        let openfunds = funds.filter { $0.status != .completed }
        let closedFunds = funds.filter { $0.status == .completed }
        
        if openfunds.isNotEmpty {
            sections.append(
                FundsListMultipleSectionViewModel.openFunds(title: "OPEN",
                                                            items: openfunds)
            )
        }

        if closedFunds.isNotEmpty {
            sections.append(
                FundsListMultipleSectionViewModel.closedFunds(title: "CLOSED",
                                                              items: closedFunds)
            )
        }
        
        return sections
    }
    
}

// MARK: - Concurrent async example

//func bindMultipleAsyncRequestsFunds(_ observable: Observable<Void>) {
//    observable
//        .flatMapLatest { _ -> Observable<([Fund], [Position], [StockSummary])> in
//            let allFunds$ = self.fundService.getFunds()
//            let singleFund$ = self.posService.getAllPositions()
//            let stocks$ = self.stockService.getPopularStocks()
//            return Observable.zip(allFunds$, singleFund$, stocks$)
//                .trackNetworkError(self.errorTracker)
//        }
//        .subscribe(onNext: { funds, positions, stocks in
//            print("I got \(funds.count) funds and \(positions.count) positions, stocks: \(stocks.count)")
//        })
//        .disposed(by: disposeBag)
//}


