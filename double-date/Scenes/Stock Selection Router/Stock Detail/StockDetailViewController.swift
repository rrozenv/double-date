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

final class StockDetailViewController: UIViewController, CustomNavBarViewable, BindableType {
  
    //MARK: - Properties
    let disposeBag = DisposeBag()
    var viewModel: StockDetailViewModel!
    private var tableView: UITableView!
    var navView: BackButtonNavView = BackButtonNavView.blackArrow
    var navBackgroundView: UIView = UIView()
    var stackView: CustomStackView<UILabel>!
    var chartRangeButtons: CustomStackView<UIButton>!
    
    //MARK: - Views
    private var buyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupNavBar()
        navView.containerView.backgroundColor = Palette.lightGrey.color
        navBackgroundView.backgroundColor = Palette.lightGrey.color
        setupChartRangeButtons()
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
        
        let initialLoad$ = Observable.of(())
        viewModel.bindFetchStockDetails(initialLoad$)
        
        //let initalChartRange$ = Observable.of(0)
        let chartButtonTapped$ = chartRangeButtons.views.map { button in
            return button.rx.tap.asObservable().map { button.tag }
        }
        //chartButtonTapped$.insert(initalChartRange$, at: 0)
        chartButtonTapped$.forEach {
            viewModel.bindSelectedRange($0.startWith(0))
        }
        
        //MARK: - Outputs
        let dataSource = StockDetailViewController.dataSource()
        viewModel.sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.chartSeries
            .drive(onNext: {
                print("Chart time series: \($0)")
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
    
    static func dataSource() -> RxTableViewSectionedReloadDataSource<MultipleSectionModel> {
        return RxTableViewSectionedReloadDataSource<MultipleSectionModel>(
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
        },
            titleForHeaderInSection: { dataSource, index in
                let section = dataSource[index]
                return section.title
        }
        )
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
    
    private func setupChartRangeButtons() {
        chartRangeButtons = CustomStackView<UIButton>(number: 2, stackViewProps: StackViewProps(axis: .horizontal, distribution: .fillEqually, spacing: 0))
        chartRangeButtons.item(at: 0).style(title: "1d",
                                            font: FontBook.AvenirMedium.of(size: 14),
                                            backColor: .red,
                                            titleColor: .white)
        chartRangeButtons.item(at: 1).style(title: "1m",
                                            font: FontBook.AvenirMedium.of(size: 14),
                                            backColor: .blue,
                                            titleColor: .white)
        
        view.addSubview(chartRangeButtons)
        chartRangeButtons.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(navView.snp.bottom)
            make.height.equalTo(50)
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
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(chartRangeButtons.snp.bottom)
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


