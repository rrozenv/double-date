//
//  PageIndicatable.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/25/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

protocol PageIndicatable: class {
    var pageIndicatorView: PageIndicatorView { get set }
}

extension PageIndicatable where Self: UIViewController, Self: CustomNavBarViewable {
    
    func setupPageIndicator(totalPageCount: Int, currentPage: Int, widthHeight: CGFloat = 6.0, selectedColor: UIColor = Palette.aqua.color, unselectedColor: UIColor = Palette.faintBlue.color) {
        let widthHeight: CGFloat = 6.0
        pageIndicatorView = PageIndicatorView(pageCount: totalPageCount, widthHeight: widthHeight, svProps: StackViewProps(axis: .horizontal, distribution: .equalSpacing, spacing: 14.0), selectedColor: selectedColor, unselectedColor: unselectedColor)
        pageIndicatorView.currentPage = currentPage

        view.addSubview(pageIndicatorView)
        pageIndicatorView.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(56)
            make.centerY.equalTo(navView)
        }
    }
    
}
