//
//  PositionListMultipleSectionModel.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/30/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxDataSources

enum PositionListMultipleSectionModel {
    case openPositons(title: String, items: [Position])
    case closedPositons(title: String, items: [Position])
}

extension PositionListMultipleSectionModel: SectionModelType {
    typealias Item = Position
    
    var items: [Position] {
        switch  self {
        case .openPositons(title: _, items: let items):
            return items.map { $0 }
        case .closedPositons(title: _, items: let items):
            return items.map { $0 }
        }
    }
    
    init(original: PositionListMultipleSectionModel, items: [Position]) {
        switch original {
        case .openPositons(title: let title, items: let items):
            self = .openPositons(title: title, items: items)
        case .closedPositons(title: let title, items: let items):
            self = .closedPositons(title: title, items: items)
        }
    }
}

extension PositionListMultipleSectionModel {
    var title: String {
        switch  self {
        case .openPositons(title: let title, items: _):
            return title
        case .closedPositons(title: let title, items: _):
            return title
        }
    }
}
