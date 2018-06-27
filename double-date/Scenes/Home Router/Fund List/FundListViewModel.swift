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
}

struct FundListViewModel {
    
    let disposeBag = DisposeBag()
    
    //MARK: - Properties
    private let fundService = FundService()
    private let errorTracker: ErrorTracker
    private let _funds = Variable<[Fund]>([])
    weak var delegate: FundListViewModelDelegate?
    
    //MARK: - Init
    init(errorTracker: ErrorTracker = ErrorTracker()) {
        self.errorTracker = errorTracker
    }
    
    //MARK: - Outputs
    var funds: Driver<[Fund]> {
        return _funds.asDriver()
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
    
    func bindCreateFund(_ observable: Observable<Void>) {
        observable
            .subscribe(onNext: {
                self.delegate?.didTapCreateFund(self)
            })
            .disposed(by: disposeBag)
    }
    
    func bindNewFund(_ observable: Observable<Fund>) {
        observable
            .subscribe(onNext: {
                self._funds.value.insert($0, at: 0)
            })
            .disposed(by: disposeBag)
    }
    
}
