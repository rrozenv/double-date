//
//  CollectionDataSource.swift
//  double-date
//
//  Created by Robert Rozenvasser on 8/3/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

//public typealias CollectionItemSelectionHandlerType = (IndexPath) -> Void
//
//open class CollectionDataSource<Provider: CollectionDataProvider, Cell: UICollectionViewCell>:
//    NSObject,
//    UICollectionViewDataSource,
//    UICollectionViewDelegate
//    where Cell: ConfigurableCell, Provider.T == Cell.T {
//
//    // MARK: - Private Properties
//    private let provider: Provider
//    private let collectionView: UICollectionView
//
//    // MARK: - Delegates
//    public var collectionItemSelectionHandler: CollectionItemSelectionHandlerType?
//
//    // MARK: - Lifecycle
//    init(collectionView: UICollectionView, provider: Provider) {
//        self.collectionView = collectionView
//        self.provider = provider
//        super.init()
//        setUp()
//    }
//
//    private func setUp() {
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
//    }
//
//    // MARK: - UICollectionViewDataSource
//    public func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return provider.numberOfSections()
//    }
//
//    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return provider.numberOfItems(in: section)
//    }
//
//    public func collectionView(_ collectionView: UICollectionView,
//                             cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier,
//                                                            for: indexPath) as? Cell else {
//                                                                return UICollectionViewCell()
//        }
//        let item = provider.item(at: indexPath)
//        if let item = item { cell.configure(item, at: indexPath) }
//        return cell
//    }
//
//    // MARK: - UICollectionViewDelegate
//    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionItemSelectionHandler?(indexPath)
//    }
//
//}



