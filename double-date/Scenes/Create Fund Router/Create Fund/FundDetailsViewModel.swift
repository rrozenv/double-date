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
    var startDate: Date = Date()
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
    
    var sections: Observable<[FundDetailsMultipleSectionModel]> {
        return Observable.of([
            FundDetailsMultipleSectionModel.nameSection(title: "Name", items: [.nameSectionItem(TextFieldTableCellProps.nameSection)]),
            FundDetailsMultipleSectionModel.maxPlayersSection(title: "Players", items: [.maxPlayersSectionItem(TextFieldTableCellProps.maxPlayersSection)]),
            FundDetailsMultipleSectionModel.maxCashBalanceSection(title: "Cash Balance", items: [.maxCashBalanceSectionItem(TextFieldTableCellProps.maxCashBalSection)]),
            FundDetailsMultipleSectionModel.startDateSection(title: "Start Date", items: [.startDateSectionItem(DatePickerTableCellProps(title: "Start Date", startDate: Date()))])
        ])
    }

    //MARK: - Inputs
    func bindDateEntry(date: Date, type: FundDetailsSectionItem) {
        switch type {
        case .startDateSectionItem: self.fundDetails.value.startDate = date
        default: break
        }
    }
    
    func bindTextEntry(text: String, type: FundDetailsSectionItem) {
        switch type {
        case .nameSectionItem: self.fundDetails.value.name = text
        case .maxPlayersSectionItem: self.fundDetails.value.maxPlayers = Int(text)!
        case .maxCashBalanceSectionItem: self.fundDetails.value.maxCashBalance = Int(text)!
        default: break
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
