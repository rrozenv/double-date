//
//  StockChartView.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/19/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import SwiftChart

final class StockChartView: UIView {
    
    // MARK: - Properties
    var chart: Chart!
    var chartRangeButtons: CustomStackView<UIButton>!
    
    // MARK: - Initialization
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupChartRangeButtons()
        setupStockChart()
    }
    
    private func setupChartRangeButtons() {
        let titles = ["1d", "1m", "3m", "6m", "1y"]
        chartRangeButtons = CustomStackView<UIButton>(number: 5, stackViewProps: StackViewProps(axis: .horizontal, distribution: .fillEqually, spacing: 0))
        chartRangeButtons.views.enumerated().forEach { index, button in
            button.style(title: titles[index],
                         font: FontBook.AvenirMedium.of(size: 14),
                         backColor: .blue,
                         titleColor: .black)
        }
        
        self.addSubview(chartRangeButtons)
        chartRangeButtons.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.height.equalTo(50)
        }
    }
    
    private func setupStockChart() {
        chart = Chart()
        chart.showXLabelsAndGrid = false
        
        self.addSubview(chart)
        chart.snp.makeConstraints { (make) in
            make.height.equalTo(180)
            make.left.right.top.equalTo(self)
            make.bottom.equalTo(chartRangeButtons.snp.top)
        }
    }
    
}

