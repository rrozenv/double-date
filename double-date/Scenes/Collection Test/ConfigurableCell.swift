//
//  ConfigurableCell.swift
//  double-date
//
//  Created by Robert Rozenvasser on 8/3/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation

public protocol ConfigurableCell {
    associatedtype T
    static var reuseIdentifier: String { get }
    func configure(_ item: T, at indexPath: IndexPath)
}

extension ConfigurableCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
