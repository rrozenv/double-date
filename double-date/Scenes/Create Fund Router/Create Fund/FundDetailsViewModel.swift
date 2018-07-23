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



protocol FundDetailsViewModelDelegate: class {
    func didEnterFund(details: FundDetails)
}

struct FundDetailsViewModel {
    
    //MARK: - Properties
    private let disposeBag = DisposeBag()
    private let fundDetails = Variable<FundDetails>(FundDetails())
    weak var delegate: FundDetailsViewModelDelegate?
    private var _sections = Variable<[FundDetailsMultipleSectionModel]>([
        FundDetailsMultipleSectionModel.nameSection(title: "Name", items: [.nameSectionItem(TextFieldTableCellProps.nameSection)]),
        FundDetailsMultipleSectionModel.maxPlayersSection(title: "Players", items: [.maxPlayersSectionItem(TextFieldTableCellProps.maxPlayersSection)]),
        FundDetailsMultipleSectionModel.maxCashBalanceSection(title: "Cash Balance", items: [.maxCashBalanceSectionItem(TextFieldTableCellProps.maxCashBalSection)]),
        FundDetailsMultipleSectionModel.startDateSection(title: "Start Date", items: [.startDateSectionItem(DatePickerTableCellProps(title: "Start Date", startDate: Date()))])
    ])
    
//    private var _testSections = Variable<[TestSectionModel]>([
//        TestSectionModel(title:"Name", items: [.nameSectionItem(TextFieldTableCellProps.nameSection)]),
//        TestSectionModel(title:"Players", items: [.maxPlayersSectionItem(TextFieldTableCellProps.maxPlayersSection)]),
//        TestSectionModel(title:"Cash Balance", items: [.maxCashBalanceSectionItem(TextFieldTableCellProps.maxCashBalSection)]),
//        TestSectionModel(title:"Start Date", items: [.startDateSectionItem(DatePickerTableCellProps(title: "Start Date", startDate: Date()))])
//    ])

    var isNextButtonEnabled: Driver<Bool> {
        return fundDetails.asDriver().map { $0.isValid }
    }
    
    var sections: Observable<[FundDetailsMultipleSectionModel]> {
        return _sections.asObservable()
    }
    
//    var testSections: Observable<[TestSectionModel]> {
//        return _testSections.asObservable()
//    }

    //MARK: - Inputs
    func bindDateEntry(_ observable: Observable<Date>) {
        observable
            .subscribe(onNext: {
                self.fundDetails.value.startDate = $0
                guard let index = self._sections.value.index(where: { $0.title == "Start Date" }) else { return }
                self._sections.value[index].items[0] = .startDateSectionItem(DatePickerTableCellProps(title: "Start Date", startDate: $0))
            })
            .disposed(by: disposeBag)
    }
    
    func bindTextEntry(text: String, type: FundDetailsSectionItem) {
//        switch type {
//        case .nameSectionItem: self.fundDetails.value.name = text
//        case .maxPlayersSectionItem: self.fundDetails.value.maxPlayers = Int(text)!
//        case .maxCashBalanceSectionItem: self.fundDetails.value.maxCashBalance = Int(text)!
//        default: break
//        }
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
