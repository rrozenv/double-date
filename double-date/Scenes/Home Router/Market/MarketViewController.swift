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
    private var searchBarView: SearchBarView!
    private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!
    private var initalLoadTrigger = PublishSubject<Void>()
    private var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private var didAppearOnce = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBarView()
        setupTableView()
        setupLoadingIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let index = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: index, animated: false)
        }
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
        
        let stockTapped$ = tableView.rx.modelSelected(StockSummary.self).asObservable()
        viewModel.bindSelectedStockSummary(stockTapped$)
        
        let searchText$ = searchBarView.searchTextField.rx.text.orEmpty.asObservable()
            .filterEmpty()
            .throttle(0.5, scheduler: MainScheduler.instance)
        viewModel.bindSearchText(searchText$)
        
        let clearSearchTapped$ = searchBarView.clearButton.rx.tap.asObservable()
             .do(onNext: { [unowned self] in self.searchBarView.searchTextField.text = nil })
        viewModel.bindClearSearch(clearSearchTapped$)
        
        //MARK: - Output
        viewModel.stocks
            .drive(tableView.rx.items(cellIdentifier: "StockListCell", cellType: UITableViewCell.self)) { row, element, cell in
                cell.textLabel?.text = "\(element.symbol)"
                cell.detailTextLabel?.text = element.companyName
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
        
        viewModel.isLoading
            .drive(activityIndicator.rx.isAnimating)
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
    
    private func setupSearchBarView() {
        searchBarView = SearchBarView()
        searchBarView.style(placeHolder: "Search friends...", backColor: Palette.lightGrey.color, searchIcon: #imageLiteral(resourceName: "IC_Search"), clearIcon: #imageLiteral(resourceName: "IC_ClearSearch"))
        
        view.addSubview(searchBarView)
        searchBarView.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.topMargin).offset(20)
            make.right.equalTo(view).offset(-26)
            make.left.equalTo(26)
            make.height.equalTo(60)
        }
    }
    
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
            make.top.equalTo(searchBarView.snp.bottom).offset(20)
            make.left.right.bottom.equalTo(view)
        }
        
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
    }
    
    private func setupLoadingIndicator() {
        activityIndicator.hidesWhenStopped = true
        
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalTo(view.snp.center)
        }
    }
    
}
