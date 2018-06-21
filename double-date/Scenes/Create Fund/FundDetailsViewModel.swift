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
    var maxPlayers: String = "0"
    var isValid: Bool {
        return name.count > 3 && maxPlayers.count > 0
    }
}

enum FundDetailType {
    case name(String)
    case maxPlayers(String)
    
    var title: String {
        switch self {
        case .name(_):
            return "Name"
        case .maxPlayers(_):
            return "Max Players"
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

struct FundDetailsViewModel {
    
    //MARK: - Properties
    private let disposeBag = DisposeBag()
    private let fundDetails = Variable<FundDetails>(FundDetails())

    var isNextButtonEnabled: Driver<Bool> {
        return fundDetails.asDriver().map { $0.isValid }
    }
    
    var tableSections: Driver<[FundDetailSection]> {
        return Driver.of([
            FundDetailSection(header: "Name", items: [FundDetailSection.Item.name("")]),
            FundDetailSection(header: "Max Players", items: [FundDetailSection.Item.maxPlayers("0")])
        ])
    }

    //MARK: - Inputs
    func bindTextEntry(textType: FundDetailType) {
        switch textType {
        case .name(let name): self.fundDetails.value.name = name
        case .maxPlayers(let count): self.fundDetails.value.maxPlayers = count
        }
    }
    
    func bindContinueButton(_ observable: Observable<Void>) {
        observable
            .subscribe(onNext: {
                print(self.fundDetails.value)
            })
            .disposed(by: disposeBag)
    }
    
}
