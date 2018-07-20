//
//  StockDetailMultipleSectionModel.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/19/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxDataSources

enum StockDetailMultipleSectionModel {
    case quoteSection(title: String, items: [StockDetailSectionItem])
    case newsSection(title: String, items: [StockDetailSectionItem])
}

enum StockDetailSectionItem {
    case quoteSectionItem(Quote)
    case newsSectionItem(NewsArticle)
}

extension StockDetailMultipleSectionModel: SectionModelType {
    typealias Item = StockDetailSectionItem
    
    var items: [StockDetailSectionItem] {
        switch  self {
        case .quoteSection(title: _, items: let items):
            return items.map {$0}
        case .newsSection(title: _, items: let items):
            return items.map {$0}
        }
    }
    
    init(original: StockDetailMultipleSectionModel, items: [StockDetailSectionItem]) {
        switch original {
        case .quoteSection(title: let title, items: let items):
            self = .quoteSection(title: title, items: items)
        case .newsSection(title: let title, items: let items):
            self = .newsSection(title: title, items: items)
        }
    }
}

extension StockDetailMultipleSectionModel {
    var title: String {
        switch self {
        case .quoteSection(title: let title, items: _):
            return title
        case .newsSection(title: let title, items: _):
            return title
        }
    }
}
