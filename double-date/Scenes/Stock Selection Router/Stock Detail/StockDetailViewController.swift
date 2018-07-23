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
    var navView: BackButtonNavView = BackButtonNavView.blackArrow
    var navBackgroundView: UIView = UIView()
    var stackView: CustomStackView<UILabel>!
    var stockChartView: StockChartView = StockChartView()
    
    //MARK: - Views
    private var buyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupNavBar()
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
        
        stockChartView.chartRangeButtons.views.forEach { button in
            let rangeTappedTag$ = button.rx.tap.asObservable().map { button.tag }
            viewModel.bindSelectedRange(rangeTappedTag$.startWith(0))
        }
        
        //MARK: - Outputs
        let dataSource = StockDetailViewController.dataSource()
        viewModel.sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.chartSeries
            .drive(onNext: { [weak self] chartData in
                print("Chart time series: \(chartData.pointsAsDouble)")
                self?.stockChartView.chart.removeAllSeries()
                self?.stockChartView.chart.add(ChartSeries(chartData.pointsAsDouble))
                self?.stockChartView.chartRangeButtons.setBackgroundColor(at: chartData.range.rawValue,
                                                           color: .red,
                                                           isUnique: true)
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
                    let cell: FundTableCell = table.dequeueReusableCell(withIdentifier: FundTableCell.defaultReusableId, for: idxPath) as! FundTableCell
                    cell.configureWith(value: quote)
                    return cell
                case let .newsSectionItem(article):
                    let cell: FundTableCell = table.dequeueReusableCell(withIdentifier: FundTableCell.defaultReusableId, for: idxPath) as! FundTableCell
                    cell.configureWith(value: article)
                    return cell
                }
        }, titleForHeaderInSection: { dataSource, index in
                let section = dataSource[index]
                return section.title
        })
    }
    
}

extension StockDetailViewController {
    
    private func createLabels() {
        stackView = CustomStackView<UILabel>(number: 3, stackViewProps: StackViewProps(axis: .vertical, distribution: .equalSpacing, spacing: 20))
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.center.equalTo(view)
        }
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(FundTableCell.self, forCellReuseIdentifier: FundTableCell.defaultReusableId)
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = UIColor.white
        
        tableView.tableHeaderView = stockChartView
        stockChartView.snp.makeConstraints { (make) in
            make.centerX.width.top.equalTo(tableView)
            //make.height.equalTo(180)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(navView.snp.bottom)
            make.left.right.bottom.equalTo(view)
        }
    }
    
    private func setupBuyButton() {
        buyButton = UIButton().rxStyle(title: "Buy", font: FontBook.AvenirMedium.of(size: 14), backColor: Palette.aqua.color, titleColor: .white)
        
        view.addSubview(buyButton)
        buyButton.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(56)
        }
    }
    
}


