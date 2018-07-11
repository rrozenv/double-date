//
//  FundDetailsViewModel.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/20/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

struct FundDetails {
    var name: String = ""
    var maxPlayers: Int = 0
    var maxCashBalance: Int = 0
    var isValid: Bool {
        return name.count > 3 && maxPlayers > 0
    }
}

enum FundDetailType {
    case name
    case maxPlayers
    case maxCashBalance
    
    var title: String {
        switch self {
        case .name: return "Name"
        case .maxPlayers: return "Max Players"
        case .maxCashBalance: return "Starting Balance"
        }
    }
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .name: return .default
        case .maxPlayers: return .decimalPad
        case .maxCashBalance: return .decimalPad
        }
    }
    
    var placeHolder: String {
        switch self {
        case .name: return "Enter Name"
        case .maxPlayers: return "0"
        case .maxCashBalance: return "0"
        }
    }
}

struct FundDetailSection {
    var header: String
    var items: [Item]
}

extension FundDetailSection: SectionModelType {
    typealias Item = FundDetailType
    
    init(original: FundDetailSection, items: [Item]) {
        self = original
        self.items = items
    }
}

protocol FundDetailsViewModelDelegate: class {
    func didEnterFund(details: FundDetails)
}

struct FundDetailsViewModel {
    
    //MARK: - Properties
    private let disposeBag = DisposeBag()
    private let fundDetails = Variable<FundDetails>(FundDetails())
    weak var delegate: FundDetailsViewModelDelegate?

    var isNextButtonEnabled: Driver<Bool> {
        return fundDetails.asDriver().map { $0.isValid }
    }
    
    var tableSections: Driver<[FundDetailSection]> {
        return Driver.of([
            FundDetailSection(header: "Name", items: [FundDetailSection.Item.name]),
            FundDetailSection(header: "Starting Cash Balance", items: [FundDetailSection.Item.maxCashBalance]),
            FundDetailSection(header: "Max Players", items: [FundDetailSection.Item.maxPlayers])
        ])
    }

    //MARK: - Inputs
    func bindTextEntry(text: String, type: FundDetailType) {
        switch type {
        case .name: self.fundDetails.value.name = text
        case .maxPlayers: self.fundDetails.value.maxPlayers = Int(text)!
        case .maxCashBalance: self.fundDetails.value.maxCashBalance = Int(text)!
        }
    }
    
    func bindContinueButton(_ observable: Observable<Void>) {
        observable
            .subscribe(onNext: {
                print(self.fundDetails.value)
                self.delegate?.didEnterFund(details: self.fundDetails.value)
            })
            .disposed(by: disposeBag)
    }
    
}
