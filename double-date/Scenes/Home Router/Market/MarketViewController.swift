//
//  MarketViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/22/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional

class MarketViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    var viewModel: MarketViewModel!
    private var continueButton: UIButton!
    private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!
    private var initalLoadTrigger = PublishSubject<Void>()
    private var didAppearOnce = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !didAppearOnce else { return }
        didAppearOnce = true
        initalLoadTrigger.onNext(())
    }
    
    deinit { print("MarketViewController deinit") }
    
    func bindViewModel() {
        //MARK: - Input
        let refreshControl$ = refreshControl.rx.controlEvent(.valueChanged).map { _ in () }
        let fetchStocks$ = Observable.of(initalLoadTrigger.asObservable(), refreshControl$).merge().share()
        viewModel.bindFetchStocks(fetchStocks$)
        
        let stockTapped$ = tableView.rx.modelSelected(Stock.self).asObservable()
        viewModel.bindSelectedStock(stockTapped$)
        
        //MARK: - Output
        viewModel.stocks
            .drive(tableView.rx.items(cellIdentifier: "StockListCell", cellType: UITableViewCell.self)) { row, element, cell in
                cell.textLabel?.text = element.companyName
                cell.detailTextLabel?.text = "\(element.latestPrice)"
            }
            .disposed(by: disposeBag)
        
        viewModel.stocks
            .map { _ in false }
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        viewModel.error
            .drive(onNext: { [weak self] in
                self?.refreshControl.endRefreshing()
                self?.tableView.contentOffset = CGPoint.zero
                self?.displayNetworkError($0)
            })
            .disposed(by: disposeBag)
    }
    
}

extension MarketViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
}

extension MarketViewController {
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StockListCell")
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = UIColor.white
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
    }
    
}
