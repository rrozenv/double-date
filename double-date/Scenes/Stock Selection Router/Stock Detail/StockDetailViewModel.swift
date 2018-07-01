//
//  StockDetailViewModel.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/27/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum PositionType: String, Codable {
    case buy, sell
}

protocol StockDetailViewModelDelegate: class {
    func didSelectPositionType(_ type: PositionType)
    func didTapBackButton()
}

struct StockDetailViewModel {
    
    //MARK: - Properties
    let disposeBag = DisposeBag()
    private let _stock: Variable<Stock>
    private let _display = PublishSubject<Void>()
    private let _shouldDismiss = PublishSubject<Void>()
    let activityIndicator = PublishSubject<Bool>()
    let errorTracker = PublishSubject<NetworkError>()
    weak var delegate: StockDetailViewModelDelegate?
    
    init(stock: Stock) {
        self._stock = Variable(stock)
    }
    
    //MARK: - Outputs
    var stock: Driver<Stock> {
        return _stock.asDriver()
    }
    
    var shouldDismiss: Observable<Void> {
        return _shouldDismiss.asObservable()
    }
    
    var isLoading: Driver<Bool> {
        return activityIndicator.asDriver(onErrorJustReturn: false)
    }
    
    var error: Driver<NetworkError> {
        return errorTracker.asDriverOnErrorJustComplete()
    }
    
    //MARK: - Inputs
    func bindSelectedPositionType(_ observable: Observable<PositionType>) {
        observable
            .subscribe(onNext: { type in
                self.delegate?.didSelectPositionType(type)
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
