//
//  SelectFundViewModel.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/29/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct FundViewModel {
    let fund: Fund
    var isSelected: Bool
}

protocol SelectFundViewModelDelegate: BackButtonNavigatable {
    func didSelectFunds(_ funds: [Fund])
}

struct SelectFundViewModel {
    
    let disposeBag = DisposeBag()
    
    //MARK: - Properties
    private let cache: Cache = Cache<Fund>(path: "funds")
    private let _funds = Variable<[FundViewModel]>([])
    private let _stock: Variable<Stock>
    weak var delegate: SelectFundViewModelDelegate?
    
    //MARK: - Init
//    init() {
//        cache.fetchObjects().asObservable()
//            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
//            .map { $0.map { FundViewModel(fund: $0, isSelected: false) } }
//            .bind(to: _funds)
//            .disposed(by: disposeBag)
//    }
    
    init(funds: [Fund], stock: Stock) {
        self._funds.value = funds.map { FundViewModel(fund: $0, isSelected: false) }
        self._stock = Variable(stock)
    }
    
    //MARK: - Outputs
    var funds: Driver<[FundViewModel]> {
        return _funds.asDriver()
    }
    
    var stock: Driver<Stock> {
        return _stock.asDriver()
    }
    
    var isDoneButtonEnabled: Driver<Bool> {
        return _funds.asDriver()
            .map { $0.filter { $0.isSelected } }
            .map { $0.isNotEmpty }
    }
    
    //MARK: - Inputs
    func bindSelectedFund(_ observable: Observable<FundViewModel>) {
        observable
            .subscribe(onNext: { fundVm in
                guard let index = self._funds.value.index(where: { $0.fund._id == fundVm.fund._id }) else {
                    fatalError("Could not fund index for fund")
                }
                self._funds.value[index].isSelected = !fundVm.isSelected
            })
            .disposed(by: disposeBag)
    }
    
    func bindContinueButton(_ observable: Observable<Void>) {
        observable
            .subscribe(onNext: {
                let selectedFunds = self._funds.value.filter { $0.isSelected }.map { $0.fund }
                self.delegate?.didSelectFunds(selectedFunds)
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
