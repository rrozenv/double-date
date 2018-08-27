//
//  FundsListMultipleSectionViewModel.swift
//  double-date
//
//  Created by Robert Rozenvasser on 8/25/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxDataSources

enum FundsListMultipleSectionViewModel {
    case openFunds(title: String, items: [Fund])
    case closedFunds(title: String, items: [Fund])
}

extension FundsListMultipleSectionViewModel: SectionModelType {
    typealias Item = Fund
    
    var items: [Fund] {
        switch  self {
        case .openFunds(title: _, items: let items):
            return items.map { $0 }
        case .closedFunds(title: _, items: let items):
            return items.map { $0 }
        }
    }
    
    init(original: FundsListMultipleSectionViewModel, items: [Fund]) {
        switch original {
        case .openFunds(title: let title, items: let items):
            self = .openFunds(title: title, items: items)
        case .closedFunds(title: let title, items: let items):
            self = .closedFunds(title: title, items: items)
        }
    }
}

extension FundsListMultipleSectionViewModel {
    var title: String {
        switch  self {
        case .openFunds(title: let title, items: _):
            return title
        case .closedFunds(title: let title, items: _):
            return title
        }
    }
}
