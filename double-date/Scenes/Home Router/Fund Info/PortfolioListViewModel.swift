//
//  FundInfoViewModel.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/3/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct PortfolioListViewModel {
    
    let disposeBag = DisposeBag()
    
    //MARK: - Properties
    private let portfolioService: PortfolioService
    private let errorTracker: ErrorTracker
    private let _portfolios = Variable<[Portfolio]>([])
    let _fund: Variable<Fund>
    
    //MARK: - Init
    init(fund: Fund, errorTracker: ErrorTracker = ErrorTracker()) {
        self.portfolioService = PortfolioService(fundId: fund._id)
        self._fund = Variable(fund)
        self.errorTracker = errorTracker
    }
    
    //MARK: - Outputs
    var portfolios: Driver<[Portfolio]> {
        return _portfolios.asDriver()
    }
    
    var error: Driver<NetworkError> {
        return errorTracker.asDriver()
    }
    
    //MARK: - Inputs
    func bindFetchPortfolios(_ observable: Observable<Void>) {
        observable
            .flatMapLatest {
                self.portfolioService.getPortfoliosFor(ids: self._fund.value.portfolios)
                    .trackNetworkError(self.errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .map { $0.sorted(by: { $0.portfolioROI > $1.portfolioROI }) }
            .bind(to: _portfolios)
            .disposed(by: disposeBag)
    }
    
}
