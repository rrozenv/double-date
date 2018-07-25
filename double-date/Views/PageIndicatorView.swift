//
//  PageIndicatorView.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/25/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

final class PageIndicatorView: UIView {
    
    private let pageCount: Int
    private let widthHeight: CGFloat
    private let stackViewProps: StackViewProps
    private let selectedColor: UIColor
    private let unselectedColor: UIColor
    private var stackView: UIStackView!
    private var views = [UIView]()
    
    var currentPage: Int = 0 {
        didSet { self.adjustButtonColors(selected: currentPage) }
    }
    
    //MARK: Initalizer Setup
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        self.pageCount = 0
        self.widthHeight = 0
        self.stackViewProps = StackViewProps(axis: .horizontal, distribution: .equalSpacing, spacing: 0)
        self.selectedColor = .clear
        self.unselectedColor = .clear
        super.init(frame: .zero)
        self.backgroundColor = UIColor.clear
        setupStackView()
    }
    
    init(pageCount: Int, widthHeight: CGFloat, svProps: StackViewProps, selectedColor: UIColor, unselectedColor: UIColor) {
        self.pageCount = pageCount
        self.widthHeight = widthHeight
        self.stackViewProps = svProps
        self.selectedColor = selectedColor
        self.unselectedColor = unselectedColor
        super.init(frame: .zero)
        self.backgroundColor = UIColor.clear
        setupStackView()
    }
    
}

extension PageIndicatorView {
    
    private func adjustButtonColors(selected tag: Int) {
        views.forEach {
            $0.backgroundColor =
                ($0.tag == tag) ? selectedColor : unselectedColor
        }
    }
    
    private func setupStackView() {
        guard pageCount > 0 else { return }
        for i in 0...pageCount - 1 {
            let view = UIView(frame: CGRect.zero)
            view.tag = i
            view.snp.makeConstraints { $0.width.height.equalTo(widthHeight) }
            view.layer.cornerRadius = widthHeight/2
            views.append(view)
        }
        stackView = UIStackView(arrangedSubviews: views)
        stackView.spacing = 10.0
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .leading
        
        self.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
}
