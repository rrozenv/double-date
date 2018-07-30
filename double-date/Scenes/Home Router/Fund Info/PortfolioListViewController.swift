//
//  FundInfoViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/3/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional

class PortfolioListViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    var viewModel: PortfolioListViewModel!
    private var continueButton: UIButton!
    private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        //createContinueButton()
    }
    
    deinit { print("PortfolioListViewController deinit") }
    
    func bindViewModel() {
        //MARK: - Input
//        let fundTapped$ = tableView.rx.modelSelected(Fund.self).asObservable()
//        viewModel.bindSelectedFund(fundTapped$)
        
        let initialLoad$ = Observable.of(())
        let refreshControl$ = refreshControl.rx.controlEvent(.valueChanged).map { _ in () }
        let fetchPortfolios$ = Observable.of(initialLoad$, refreshControl$).merge().share()
        viewModel.bindFetchPortfolios(fetchPortfolios$)
        
        //MARK: - Output
        viewModel.portfolios
            .drive(tableView.rx.items(cellIdentifier: LeaderBoardTableCell.defaultReusableId, cellType: LeaderBoardTableCell.self)) { row, element, cell in
                cell.configureWith(value: element, index: row)
            }
            .disposed(by: disposeBag)
        
        viewModel.portfolios
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

extension PortfolioListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
}

extension PortfolioListViewController {
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(LeaderBoardTableCell.self, forCellReuseIdentifier: LeaderBoardTableCell.defaultReusableId)
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
