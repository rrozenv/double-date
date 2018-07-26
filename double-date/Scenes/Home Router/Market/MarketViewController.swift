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

final class LoadingView: UIView {
    
    var loadingIndicator: UIActivityIndicatorView!
    var backgroundView: UIView!
    
    // MARK: - Initialization
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.clear
        setupBackgroundView()
        setupLoadingIndicator()
    }
    
    private func setupBackgroundView() {
        backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        self.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { (make) in
            make.width.height.equalTo(60)
            make.edges.equalTo(self)
        }
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        
        backgroundView.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { (make) in
            make.center.equalTo(backgroundView)
        }
    }
}

protocol LoadingIndicatable: class {
    var loadingView: LoadingView { get set }
}

extension LoadingIndicatable where Self: UIViewController {
    func setupLoadingIndicator() {
        loadingView.isHidden = true
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints { (make) in
            make.center.equalTo(view)
        }
    }
    
    func animateLoadingView(_ isLoading: Bool) {
        isLoading ? self.loadingView.loadingIndicator.startAnimating() :
            self.loadingView.loadingIndicator.stopAnimating()
        self.loadingView.isHidden = isLoading ? false : true
    }
}

class MarketViewController: UIViewController, BindableType, LoadingIndicatable {
    
    let disposeBag = DisposeBag()
    var viewModel: MarketViewModel!
    private var continueButton: UIButton!
    private var searchBarView: SearchBarView!
    private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!
    private var emptyLabelsSv: UIStackView!
    var loadingView: LoadingView = LoadingView()
    
    private var initalLoadTrigger = PublishSubject<Void>()
    private var didAppearOnce = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBarView()
        setupTableView()
        setupLoadingIndicator()
        setupEmptyView()
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
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        //MARK: - Input
        let refreshControl$ = refreshControl.rx.controlEvent(.valueChanged).map { _ in () }.do(onNext: { [unowned self] in
            self.searchBarView.searchTextField.text = nil
        })
        let fetchStocks$ = Observable.of(initalLoadTrigger.asObservable(), refreshControl$).merge().share()
        viewModel.bindFetchStocks(fetchStocks$)
        
        let stockTapped$ = tableView.rx.modelSelected(StockSummary.self).asObservable()
        viewModel.bindSelectedStockSummary(stockTapped$)
        
        let searchText$ = searchBarView.searchTextField.rx.text.orEmpty.asObservable()
            .throttle(0.5, scheduler: MainScheduler.instance)
        viewModel.bindSearchText(searchText$)
        
//        let clearSearchTapped$ = searchBarView.clearButton.rx.tap.asObservable()
//             .do(onNext: { [unowned self] in self.searchBarView.searchTextField.text = nil })
//        viewModel.bindClearSearch(clearSearchTapped$)
        
        //MARK: - Output
        viewModel.stocks
            .drive(tableView.rx.items(cellIdentifier: StockSearchTableCell.defaultReusableId, cellType: StockSearchTableCell.self)) { row, element, cell in
                cell.configureWith(value: element)
            }
            .disposed(by: disposeBag)
        
        viewModel.stocks
            .map { _ in false }
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        viewModel.displayEmptyView
            .drive(emptyLabelsSv.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.error
            .drive(onNext: { [weak self] in
                self?.refreshControl.endRefreshing()
                self?.tableView.contentOffset = CGPoint.zero
                self?.displayNetworkError($0)
            })
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .drive(onNext: { [weak self] in
                self?.animateLoadingView($0)
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
    
    private func setupSearchBarView() {
        searchBarView = SearchBarView()
        searchBarView.style(placeHolder: "Search by ticker or company...", backColor: Palette.faintBlue.color, searchIcon: #imageLiteral(resourceName: "IC_Search_LightBlue"), clearIcon: #imageLiteral(resourceName: "IC_ClearSearch"))
        
        view.addSubview(searchBarView)
        searchBarView.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.topMargin).offset(20)
            make.right.equalTo(view).offset(-20)
            make.left.equalTo(20)
            make.height.equalTo(60)
        }
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(StockSearchTableCell.self, forCellReuseIdentifier: StockSearchTableCell.defaultReusableId)
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        tableView.keyboardDismissMode = .onDrag
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(searchBarView.snp.bottom).offset(20)
            make.left.right.bottom.equalTo(view)
        }
        
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
    }
    
    private func setupEmptyView() {
        let titleLabel = UILabel(title: "No Results.").rxStyle(font: FontBook.AvenirHeavy.of(size: 14), color: Palette.lightBlue.color)
        let bodyLabel = UILabel(title: "Make sure the ticker or company name matches exactly.").rxStyle(font: FontBook.AvenirMedium.of(size: 12), color: Palette.lightBlue.color)
        bodyLabel.numberOfLines = 0
        
        emptyLabelsSv = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        emptyLabelsSv.axis = .vertical
        emptyLabelsSv.distribution = .equalSpacing
        emptyLabelsSv.spacing = 5.0
        
        view.addSubview(emptyLabelsSv)
        emptyLabelsSv.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view).offset(-60)
            make.width.equalTo(view).multipliedBy(0.6)
        }
    }
    
}
