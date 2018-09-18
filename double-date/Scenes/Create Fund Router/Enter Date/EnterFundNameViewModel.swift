//
//  EnterFundNameViewModel.swift
//  double-date
//
//  Created by Robert Rozenvasser on 8/28/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol EnterDateViewModelDelegate: BackButtonNavigatable {
    func didEnter(date: Date, type: EnterDateViewModel.DateType)
}

struct EnterDateViewModel {
    
    enum DateType {
        case start, end
    }
    
    //MARK: - Properties
    private let disposeBag = DisposeBag()
    let dayText = Variable("")
    let monthText = Variable("")
    let yearText = Variable("")
    private let dateFormat = "dd-MM-yyyy"
    private let dateType: DateType
    weak var delegate: EnterDateViewModelDelegate?
    
    init(dateType: DateType) {
        self.dateType = dateType
    }
    
    var pageIndicatorInfo: Driver<(total:Int, current: Int)> {
        switch dateType {
        case .start: return Driver.of((5, 2))
        case .end: return Driver.of((5, 3))
        }
    }
    
    var isNextButtonEnabled: Driver<Bool> {
        return Observable.combineLatest(dayText.asObservable(),
                                        monthText.asObservable(),
                                        yearText.asObservable()) { (day, month, year) in
                                            "\(day)-\(month)-\(year)"
            }
            .map { $0.asDate(format: self.dateFormat) }
            .map {
                if let validDate = $0, validDate > Date() {
                    return true
                } else {
                    return false
                }
            }
            .asDriver(onErrorJustReturn: false)
    }
    
    var titleHeaderText: Driver<String> {
        return Driver.of("When will this \ngame \(dateType == .start ? "start" : "end")?")
    }
    
    //MARK: - Inputs
    func bindContinueButton(_ observable: Observable<Void>) {
        observable
            .map { "\(self.dayText.value)" + " \(self.monthText.value)" + " \(self.yearText.value)" }
            .map { $0.asDate(format: self.dateFormat) }
            .filterNil()
            .subscribe(onNext: {
                self.delegate?.didEnter(date: $0, type: self.dateType)
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
