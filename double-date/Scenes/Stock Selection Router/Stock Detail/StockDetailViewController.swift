//
//  StockDetailViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/27/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import SwiftChart

final class StockDetailViewController: UIViewController, CustomNavBarViewable, BindableType {
  
    //MARK: - Properties
    let disposeBag = DisposeBag()
    var viewModel: StockDetailViewModel!
    private var tableView: UITableView!
    private var dataSource: RxTableViewSectionedReloadDataSource<StockDetailMultipleSectionModel>!
    
    var navView: BackButtonNavView = BackButtonNavView.blackArrow
    var navBackgroundView: UIView = UIView()
    var navViewLabels: CustomStackView<UILabel>!
    var stockChartView: StockChartView = StockChartView()
    
    //MARK: - Views
    private var buyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupNavBar()
        createNavViewLabels()
        setupTableView()
        setupBuyButton()
    }
    
    deinit { print("StockDetailViewController deinit") }
    
    func bindViewModel() {
        //MARK: - Inputs
        let buyTapped$ = buyButton.rx.tap.asObservable()
        viewModel.bindSelectedPositionType(buyTapped$.map { PositionType.buy })
        
        let backTapped$ = navView.backButton.rx.tap.asObservable()
        viewModel.bindBackButton(backTapped$)
        
//        let initialLoad$ = Observable.of(())
//        viewModel.bindFetchStockDetails(initialLoad$)
        
        stockChartView.chartButtons.buttons.forEach { button in
            let rangeTappedTag$ = button.rx.tap.asObservable().map { button.tag }
            viewModel.bindSelectedRange(rangeTappedTag$.startWith(0))
        }
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        //MARK: - Outputs
        dataSource = StockDetailViewController.dataSource()
        viewModel.sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.stock
            .drive(onNext: { [unowned self] in
                self.navViewLabels.item(at: 0).text = $0.quote.symbol.uppercased()
                self.navViewLabels.item(at: 1).text = $0.quote.companyName
                self.stockChartView.priceLabel.text = "\($0.quote.latestPrice.asCurreny)"
                self.stockChartView.returnLabel.text = "\($0.quote.changePercent.asPercentage)"
            })
            .disposed(by: disposeBag)
        
        viewModel.chartSeries
            .drive(onNext: { [weak self] chartData in
                print("Chart time series: \(chartData.pointsAsDouble)")
                self?.stockChartView.chart.removeAllSeries()
                let series = ChartSeries(chartData.pointsAsDouble)
                //series.area = true
                series.color = Palette.aqua.color
                self?.stockChartView.chart.add(series)
                self?.stockChartView.chartButtons.adjustButtonStyle(selected: chartData.range.rawValue)
            })
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .drive(onNext: {
                print("isLoading: \($0)")
            })
            .disposed(by: disposeBag)
        
        viewModel.error
            .drive(onNext: { [weak self] in
                self?.displayNetworkError($0)
            })
            .disposed(by: disposeBag)
    }
    
}

extension StockDetailViewController {
    
    static func dataSource() -> RxTableViewSectionedReloadDataSource<StockDetailMultipleSectionModel> {
        return RxTableViewSectionedReloadDataSource<StockDetailMultipleSectionModel>(
            configureCell: { (dataSource, table, idxPath, _) in
                switch dataSource[idxPath] {
                case let .quoteSectionItem(quote):
                    let cell: FundSummaryTableCell = table.dequeueReusableCell(withIdentifier: FundSummaryTableCell.defaultReusableId, for: idxPath) as! FundSummaryTableCell
                    cell.configureWith(value: quote)
                    return cell
                case let .newsSectionItem(article):
                    let cell: FundSummaryTableCell = table.dequeueReusableCell(withIdentifier: FundSummaryTableCell.defaultReusableId, for: idxPath) as! FundSummaryTableCell
                    cell.configureWith(value: article)
                    return cell
                }
        })
    }
    
}

extension StockDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42.0 //CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel().rxStyle(font: FontBook.AvenirHeavy.of(size: 11), color: Palette.lightBlue.color)
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(23)
            make.centerY.equalTo(view)
        }
        label.text = dataSource[section].title
        return view
    }

}

extension StockDetailViewController {
    
    private func createNavViewLabels() {
        navViewLabels = CustomStackView<UILabel>(number: 2, stackViewProps: StackViewProps(axis: .vertical, distribution: .equalSpacing, spacing: 1.0))
        navViewLabels.item(at: 0).styleWith(LabelStyle(font: FontBook.AvenirHeavy.of(size: 14.0), color: Palette.darkNavy.color, alignment: .center, numberOfLines: 1))
        navViewLabels.item(at: 1).styleWith(LabelStyle(font: FontBook.AvenirMedium.of(size: 11.0), color: Palette.lightBlue.color, alignment: .center, numberOfLines: 1))
        
        view.addSubview(navViewLabels)
        navViewLabels.snp.makeConstraints { (make) in
            make.center.equalTo(navView)
        }
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(FundSummaryTableCell.self, forCellReuseIdentifier: FundSummaryTableCell.defaultReusableId)
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        
        //stockChartView.dropShadow()
        tableView.tableHeaderView = stockChartView
        stockChartView.snp.makeConstraints { (make) in
            make.centerX.width.top.equalTo(tableView)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(navView.snp.bottom)
            make.left.right.bottom.equalTo(view)
        }
    }
    
    private func setupBuyButton() {
        buyButton = UIButton().rxStyle(title: "BUY", font: FontBook.AvenirHeavy.of(size: 12), backColor: Palette.aqua.color, titleColor: .white)
        buyButton.dropShadow()
        
        view.addSubview(buyButton)
        buyButton.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(56)
        }
    }
    
}


