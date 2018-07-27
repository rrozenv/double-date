//
//  FundListViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/22/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional

class FundListViewController: UIViewController, CustomNavBarViewable, BindableType {
    
    let disposeBag = DisposeBag()
    var viewModel: FundListViewModel!
    
    var navView = UIView()
    var navBackgroundView: UIView = UIView()
    private var continueButton: UIButton!
    private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.appBackground.color
        setupNavBar()
        navView.backgroundColor = Palette.appBackground.color
        navBackgroundView.backgroundColor = Palette.appBackground.color
        setTitleLabel(UILabel(title: "MY FUNDS").rxStyle(font: FontBook.AvenirHeavy.of(size: 11), color: Palette.lightBlue.color))
        setupTableView()
        createContinueButton()
    }
    
    deinit { print("FundListViewController deinit") }
    
    func bindViewModel() {
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        //MARK: - Input
        let createTapped$ = continueButton.rx.tap.asObservable()
        viewModel.bindCreateFund(createTapped$)
        
        let fundTapped$ = tableView.rx.modelSelected(Fund.self).asObservable()
        viewModel.bindSelectedFund(fundTapped$)
        
        let initialLoad$ = Observable.of(())
        let refreshControl$ = refreshControl.rx.controlEvent(.valueChanged).map { _ in () }
        let fetchFunds$ = Observable.of(initialLoad$, refreshControl$).merge().share()
        viewModel.bindFetchFunds(fetchFunds$)
        
        //MARK: - Output
        viewModel.funds
            .drive(tableView.rx.items(cellIdentifier: FundSummaryTableCell.defaultReusableId, cellType: FundSummaryTableCell.self)) { row, element, cell in
                cell.configureWith(value: element)
            }
            .disposed(by: disposeBag)
        
        viewModel.funds
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
    
    private func toCreateFundRouter() {
        let navVc = UINavigationController()
        let router = CreateFundRouter()
        
        let newFund$ = router.newFund.asObservable()
            .filterNil()
        viewModel.bindNewFund(newFund$, disposeBag: nil)
        
        navigationController?.present(navVc, animated: true, completion: nil)
    }
    
    private func createContinueButton() {
        continueButton = UIButton()
        continueButton.imageView?.contentMode = .scaleAspectFit
        continueButton.setImage(#imageLiteral(resourceName: "IC_Plus"), for: .normal)
        continueButton.dropShadow()
        
        view.addSubview(continueButton)
        continueButton.snp.makeConstraints { (make) in
            make.right.equalTo(view).offset(-20)
            make.centerY.equalTo(navView).offset(2)
        }
    }
    
}

extension FundListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
}

extension FundListViewController {
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(FundSummaryTableCell.self, forCellReuseIdentifier: FundSummaryTableCell.defaultReusableId)
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = Palette.appBackground.color
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            //make.edges.equalTo(view)
            make.left.bottom.right.equalTo(view)
            make.top.equalTo(navView.snp.bottom)
        }
        
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
    }
    
}
