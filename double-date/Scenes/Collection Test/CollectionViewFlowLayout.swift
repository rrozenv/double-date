//
//  CollectionViewFlowLayout.swift
//  double-date
//
//  Created by Robert Rozenvasser on 8/3/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

final class CollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    private var itemSpacing: CGFloat = 0
    private var itemsPerRow: CGFloat = 0
    private var itemHeight: CGFloat = 0
    
    private override init() { super.init() }
    
    convenience init(itemSpacing: CGFloat = 0,
                     itemsPerRow: CGFloat = 0,
                     itemHeight: CGFloat = 100.0,
                     scrollDirection: UICollectionViewScrollDirection = .horizontal,
                     sectionInset: UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0),
                     isSelfSizing: Bool = false) {
        self.init()
        self.itemSpacing = itemSpacing
        self.itemsPerRow = itemsPerRow
        self.itemHeight = itemHeight
        self.minimumLineSpacing = itemSpacing
        self.minimumInteritemSpacing = itemSpacing
        self.scrollDirection = scrollDirection
        self.sectionInset = sectionInset
        if isSelfSizing { self.estimatedItemSize = CGSize(width: 1, height: 1) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func itemWidth() -> CGFloat {
        return 100
        //return //(UIScreen.main.bounds.width/self.itemsPerRow) - self.itemSpacing
    }
    
    override var itemSize: CGSize {
        get { return CGSize(width: itemWidth(), height: itemHeight) }
        set { self.itemSize = CGSize(width: itemWidth(), height: itemHeight) }
    }
    
}
