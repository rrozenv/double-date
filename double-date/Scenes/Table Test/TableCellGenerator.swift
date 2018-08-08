//
//  TableCellGenerator.swift
//  double-date
//
//  Created by Robert Rozenvasser on 8/7/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

typealias UserCellWrapper = CellModelWrapper<UserCell, UIColor>
typealias RandomCellWrapper = CellModelWrapper<RandomCell, String>
typealias TableHeaderWrapper = CellModelWrapper<TableHeaderView, String>

protocol CellConfigurator {
    static var reuseId: String { get }
    func configure(cell: UIView)
}

class CellModelWrapper<CellType: ConfigurableCell, DataType>: CellConfigurator
      where CellType.DataType == DataType,
            CellType: UIView {
    
    static var reuseId: String { return CellType.reuseIdentifier }
    let item: DataType
    
    init(item: DataType) {
        self.item = item
    }
    
    func configure(cell: UIView) {
        guard let cell = cell as? CellType else { return }
        cell.configure(data: item)
    }
}

//protocol TableHeaderConfigurator {
//    func configure(view: UIView)
//}

//class TableHeaderWrapper<CellType: ConfigurableCell, DataType>: CellConfigurator
//    where CellType.DataType == DataType,
//    CellType: UIView {
//    
//    static var reuseId: String { return CellType.reuseIdentifier }
//    let item: DataType
//    
//    init(item: DataType) {
//        self.item = item
//    }
//    
//    func configure(cell: UIView) {
//        guard let view = cell as? CellType else { return }
//        view.configure(data: item)
//    }
//    
//}



