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

protocol EnterFundNameViewModelDelegate: BackButtonNavigatable {
    func didEnterFund(name: String)
}

struct EnterFundNameViewModel {
    
    //MARK: - Properties
    private let disposeBag = DisposeBag()
    private let text = Variable("")
    weak var delegate: EnterFundNameViewModelDelegate?
    
    var isNextButtonEnabled: Driver<Bool> {
        return text.asDriver().map { $0.isNotEmpty }
    }
    
    var titleHeaderText: Driver<String> {
        return Driver.of("What's the name \n of your stock game?")
    }
    
    //MARK: - Inputs
    func bindTextEntry(_ observable: Observable<String>) {
        observable
            .bind(to: text)
            .disposed(by: disposeBag)
    }
    
    func bindContinueButton(_ observable: Observable<Void>) {
        observable
            .subscribe(onNext: {
                self.delegate?.didEnterFund(name: self.text.value)
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
    
    var isNextButtonEnabled: Driver<Bool> {
        return Observable.combineLatest(dayText.asObservable(),
                                        monthText.asObservable(),
                                        yearText.asObservable()) { (day, month, year) in
                                            "\(day)-\(month)-\(year)"
            }
            .map { $0.asDate(format: self.dateFormat) }
            .do(onNext: { if let date = $0 { print(date) } })
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
        return Driver.of("What's the name \nof your stock game?")
    }
    
    //MARK: - Inputs
//    func bindDayTextEntry(_ observable: Observable<String>) {
//        observable
//            .bind(to: dayText)
//            .disposed(by: disposeBag)
//    }
//
//    func bindDayTextEntryTest(_ observable: Observable<String>) {
//        observable
//            .bind(to: dayText)
//            .disposed(by: disposeBag)
//    }
//
//    func bindMonthTextEntry(_ observable: Observable<String>) {
//        observable
//            .bind(to: monthText)
//            .disposed(by: disposeBag)
//    }
//
//    func bindYearTextEntry(_ observable: Observable<String>) {
//        observable
//            .bind(to: yearText)
//            .disposed(by: disposeBag)
//    }
    
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
