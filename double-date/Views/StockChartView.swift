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
    var containerView: UIView!
    var priceLabel: UILabel!
    var returnLabel: UILabel!
    var chart: Chart!
    var chartButtons: TabOptionsView!
    
    // MARK: - Initialization
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupContainerView()
        setupChartRangeButtons()
        setupStockChart()
        setupPriceLabels()
    }
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = .white
        
        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    private func setupChartRangeButtons() {
        let titles = ["1d", "1m", "3m", "6m", "1y"]
        chartButtons = TabOptionsView(appearence: TabAppearence(type: .underline(Palette.aqua.color), itemTitles: titles, height: 50.0, selectedBkgColor: .white, selectedTitleColor: Palette.aqua.color, notSelectedBkgColor: .white, notSelectedTitleColor: Palette.lightGrey.color))
        containerView.addSubview(chartButtons)
        chartButtons.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(containerView)
        }
    }
    
    private func setupStockChart() {
        chart = Chart()
        chart.showXLabelsAndGrid = false
        chart.showYLabelsAndGrid = false
        chart.areaAlphaComponent = 0.1
        chart.highlightLineColor = Palette.aqua.color
        chart.topInset = 0
        chart.bottomInset = 10
        chart.gridColor = .white
        chart.axesColor = .white
        //chart.dropShadow()
        
        containerView.addSubview(chart)
        chart.snp.makeConstraints { (make) in
            make.height.equalTo(220)
            make.left.right.equalTo(containerView)
            make.bottom.equalTo(chartButtons.snp.top)
        }
    }
    
    private func setupPriceLabels() {
        priceLabel = UILabel().rxStyle(font: FontBook.AvenirHeavy.of(size: 17), color: Palette.darkNavy.color)
        returnLabel = UILabel().rxStyle(font: FontBook.AvenirMedium.of(size: 14), color: Palette.aqua.color)
        
        let sv = UIStackView(arrangedSubviews: [priceLabel, returnLabel])
        sv.axis = .vertical
        sv.spacing = 2.0
        
        containerView.addSubview(sv)
        sv.snp.makeConstraints { (make) in
            make.top.equalTo(containerView).offset(10)
            make.centerX.equalTo(containerView)
            make.bottom.equalTo(chart.snp.top).offset(-20)
        }
    }
    
}

