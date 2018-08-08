//
//  CellActionProxy.swift
//  double-date
//
//  Created by Robert Rozenvasser on 8/7/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

final class CellActionProxy {
    
    // Stores actions
    private var actions = [String: ((CellConfigurator, UIView) -> Void)]()
    
    // Invokes cell action and notifies subscribers
    func invoke(action: CellAction, cell: UIView, configurator: CellConfigurator) {
        let key = "\(action.hashValue)\(type(of: configurator).reuseId)"
        if let action = self.actions[key] {
            action(configurator, cell)
        }
    }
    
    // Subscribe to cell action
    // Return self to chain subscription
    func on<CellType, DataType>(_ action: CellAction, handler: @escaping ((CellModelWrapper<CellType, DataType>, CellType) -> Void)) -> Self {
        let key = "\(action.hashValue)\(CellType.reuseIdentifier)"
        self.actions[key] = { (configurator, cell) in
            guard let c = configurator as? CellModelWrapper<CellType, DataType>,
                let cell = cell as? CellType else { return }
            handler(c, cell)
        }
        return self
    }
    
}
