//
//  CreateFundFormViewModel.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/23/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct FundDetails {
    var name: String = ""
    var maxCashBalance: String = "0"
    var startDate: Date = Date()
    var endDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    
    var isValid: Bool {
        guard let cashDigitsOnly = Int(maxCashBalance.digits) else { return false }
        return name.count > 3 && (cashDigitsOnly/10) > 0 && startDate < endDate
    }
}

protocol CreateFundFormViewModelDelegate: BackButtonNavigatable {
    func didEnterFund(details: FundDetails)
}

enum CreateFundFormInputType {
    case name, maxPlayers, maxCashBalance, startDate, endDate
}

struct CreateFundFormViewModel {
    
    //MARK: - Properties
    private let disposeBag = DisposeBag()
    private let fundDetails = Variable<FundDetails>(FundDetails())
    weak var delegate: CreateFundFormViewModelDelegate?
    
    var isNextButtonEnabled: Driver<Bool> {
        return fundDetails.asDriver().map { $0.isValid }
    }
    
    var selectedDates: Driver<(start: String, end: String)> {
        return fundDetails.asDriver().map { ($0.startDate.dayMonthYearString, $0.endDate.dayMonthYearString) }
    }
    
    //MARK: - Inputs
    func bindDateEntry(_ observable: Observable<Date>, type: CreateFundFormInputType) {
        observable
            .subscribe(onNext: {
                switch type {
                case .startDate: self.fundDetails.value.startDate = $0
                case .endDate: self.fundDetails.value.endDate = $0
                default: break
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bindTextEntry(_ observable: Observable<String>, type: CreateFundFormInputType) {
        observable
            .subscribe(onNext: { text in
                switch type {
                case .name: self.fundDetails.value.name = text
                case .maxCashBalance: self.fundDetails.value.maxCashBalance = text
                default: break
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bindContinueButton(_ observable: Observable<Void>) {
        observable
            .subscribe(onNext: {
                print(self.fundDetails.value)
                self.delegate?.didEnterFund(details: self.fundDetails.value)
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
