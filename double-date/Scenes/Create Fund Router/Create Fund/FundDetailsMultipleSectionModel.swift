//
//  FundDetailsMultipleSectionModel.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/22/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxDataSources

struct TextFieldTableCellProps {
    let title: String
    let keyBoardType: UIKeyboardType
    let placeHolderText: String
}

extension TextFieldTableCellProps {
    static var nameSection: TextFieldTableCellProps {
        return TextFieldTableCellProps(title: "Name",
                                       keyBoardType: .default,
                                       placeHolderText: "Enter Name...")
    }
    
    static var maxCashBalSection: TextFieldTableCellProps {
        return TextFieldTableCellProps(title: "Inital Investment",
                                       keyBoardType: .decimalPad,
                                       placeHolderText: "Enter Amount...")
    }
    
    static var maxPlayersSection: TextFieldTableCellProps {
        return TextFieldTableCellProps(title: "Max Players",
                                       keyBoardType: .decimalPad,
                                       placeHolderText: "0")
    }
}

enum FundDetailsMultipleSectionModel {
    case nameSection(title: String, items: [FundDetailsSectionItem])
    case maxCashBalanceSection(title: String, items: [FundDetailsSectionItem])
    case maxPlayersSection(title: String, items: [FundDetailsSectionItem])
    case startDateSection(title: String, items: [FundDetailsSectionItem])
}

enum FundDetailsSectionItem {
    case nameSectionItem(TextFieldTableCellProps)
    case maxCashBalanceSectionItem(TextFieldTableCellProps)
    case maxPlayersSectionItem(TextFieldTableCellProps)
    case startDateSectionItem(DatePickerTableCellProps)
    
//    var title: String {
//        switch self {
//        case .nameSectionItem: return "Name"
//        case .maxPlayersSectionItem: return "Max Players"
//        case .maxCashBalanceSectionItem: return "Starting Balance"
//
//        }
//    }
//
//    var keyboardType: UIKeyboardType {
//        switch self {
//        case .nameSectionItem: return .default
//        case .maxPlayersSectionItem: return .decimalPad
//        case .maxCashBalanceSectionItem: return .decimalPad
//        }
//    }
//
//    var placeHolder: String {
//        switch self {
//        case .nameSectionItem: return "Enter Name"
//        case .maxPlayersSectionItem: return "0"
//        case .maxCashBalanceSectionItem: return "0"
//        }
//    }
}

extension FundDetailsMultipleSectionModel: SectionModelType {
    typealias Item = FundDetailsSectionItem
    
    var items: [FundDetailsSectionItem] {
        switch  self {
        case .nameSection(title: _, items: let items):
            return items.map { $0 }
        case .maxPlayersSection(title: _, items: let items):
            return items.map { $0 }
        case .maxCashBalanceSection(title: _, items: let items):
            return items.map { $0 }
        case .startDateSection(title: _, items: let items):
            return items.map { $0 }
        }
    }
    
    init(original: FundDetailsMultipleSectionModel, items: [FundDetailsSectionItem]) {
        switch original {
        case .nameSection(title: let title, items: let items):
            self = .nameSection(title: title, items: items)
        case .maxPlayersSection(title: let title, items: let items):
            self = .maxPlayersSection(title: title, items: items)
        case .maxCashBalanceSection(title: let title, items: let items):
            self = .maxCashBalanceSection(title: title, items: items)
        case .startDateSection(title: let title, items: let items):
            self = .startDateSection(title: title, items: items)
        }
    }
}

extension FundDetailsMultipleSectionModel {
    var title: String {
        switch self {
        case .nameSection(title: let title, items: _):
            return title
        case .maxPlayersSection(title: let title, items: _):
            return title
        case .maxCashBalanceSection(title: let title, items: _):
            return title
        case .startDateSection(title: let title, items: _):
            return title
        }
    }
}
