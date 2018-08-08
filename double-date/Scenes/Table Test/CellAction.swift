//
//  CellAction.swift
//  double-date
//
//  Created by Robert Rozenvasser on 8/7/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

struct CellActionEventData {
    let action: CellAction
    let cell: UIView
}

enum CellAction: Hashable {
    case didSelect
    case willDisplay
    case custom(String)
    
    var hashValue: Int {
        switch self {
        case .didSelect: return 0
        case .willDisplay: return 1
        case .custom(let value): return value.hashValue
        }
    }
    
    static func ==(lhs: CellAction, rhs: CellAction) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension CellAction {
    //Publishes custom cell action events
    static let notificationName = NSNotification.Name(rawValue: "CellAction")
    public func invoke(cell: UIView) {
        NotificationCenter.default.post(name: CellAction.notificationName,
                                        object: nil,
                                        userInfo: ["data": CellActionEventData(action: self, cell: cell)])
    }
}

