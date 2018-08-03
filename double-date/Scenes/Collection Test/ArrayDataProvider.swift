//
//  ArrayDataProvider.swift
//  double-date
//
//  Created by Robert Rozenvasser on 8/3/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation

public protocol CollectionDataProvider {
    associatedtype T
    func numberOfSections() -> Int
    func numberOfItems(in section: Int) -> Int
    func item(at indexPath: IndexPath) -> T?
    func updateItem(at indexPath: IndexPath, value: T)
}

public class ArrayDataProvider<T>: CollectionDataProvider {
    // MARK: - Internal Properties
    var items: [[T]] = []
    
    // MARK: - Lifecycle
    init(array: [[T]] = [[]]) {
        items = array
    }
    
    // MARK: - CollectionDataProvider
    public func numberOfSections() -> Int {
        return items.count
    }
    
    public func numberOfItems(in section: Int) -> Int {
        guard section >= 0 && section < items.count else {
            return 0
        }
        return items[section].count
    }
    
    public func item(at indexPath: IndexPath) -> T? {
        guard indexPath.section >= 0 &&
            indexPath.section < items.count &&
            indexPath.row >= 0 &&
            indexPath.row < items[indexPath.section].count else
        {
            return nil
        }
        return items[indexPath.section][indexPath.row]
    }
    
    public func updateItem(at indexPath: IndexPath, value: T) {
        guard indexPath.section >= 0 &&
            indexPath.section < items.count &&
            indexPath.row >= 0 &&
            indexPath.row < items[indexPath.section].count else
        {
            return
        }
        items[indexPath.section][indexPath.row] = value
    }
    
}
