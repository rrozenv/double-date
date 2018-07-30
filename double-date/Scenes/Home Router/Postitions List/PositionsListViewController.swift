//
//  PositionsListViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/4/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

final class PositionsListViewController: UIViewController, BindableType {
    
    //MARK: - Properties
    let disposeBag = DisposeBag()
    var viewModel: PositionsListViewModel!
    
    //MARK: - Views
    private var logoutButton: UIButton!
    private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!
    private var initalLoadTrigger = PublishSubject<Void>()
    private var didAppearOnce = false
    var _scrollViewDidScroll = PublishSubject<UIScrollView>()
    var _shouldClosePosition = PublishSubject<Position>()
    var _shouldFetchUpdatedFund = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !didAppearOnce else { return }
        didAppearOnce = true
        initalLoadTrigger.onNext(())
    }
    
    deinit { print("PositionsListViewController deinit") }
    
    func bindViewModel() {
        let refreshControl$ = refreshControl.rx.controlEvent(.valueChanged).map { _ in () }
        viewModel.bindFetchPositions(refreshControl$)
        
        let closePosition$ = _shouldClosePosition.asObservable()
        viewModel.bindClosePosition(closePosition$)
        
        let fetchUpdatedFund$ = _shouldFetchUpdatedFund.asObservable()
        viewModel.bindFetchUpdatedFund(fetchUpdatedFund$)
        
        tableView.rx.modelSelected(Position.self).asObservable()
            .filter { $0.status == .closed }
            .subscribe(onNext: { [unowned self] (pos) in
                let alertVc = AlertViewController(alertInfo: AlertViewController.AlertInfo.closePositionAlert(position: pos), okAction: {
                    self._shouldClosePosition.onNext(pos)
                }, cancelAction: nil)
                self.displayAlert(vc: alertVc)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        //MARK: - Output
        let dataSource = PositionsListViewController.dataSource()
        viewModel.sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
//        viewModel.positions
//            .drive(tableView.rx.items(cellIdentifier: PositionSummaryTableCell.defaultReusableId, cellType: PositionSummaryTableCell.self)) { row, element, cell in
//                cell.configureWith(value: element)
//            }
//            .disposed(by: disposeBag)
        
        viewModel.displayDidClosePositionAlert
            .drive(onNext: { [unowned self] pos in
                let alertVc = AlertViewController(alertInfo: AlertViewController.AlertInfo.closePositionConfirmation(position: pos), okAction: nil)
                self._shouldFetchUpdatedFund.onNext(())
                self.displayAlert(vc: alertVc)
            })
            .disposed(by: disposeBag)
        
        viewModel.sections.asDriverOnErrorJustComplete()
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

extension PositionsListViewController {
    
    static func dataSource() -> RxTableViewSectionedReloadDataSource<PositionListMultipleSectionModel> {
        return RxTableViewSectionedReloadDataSource<PositionListMultipleSectionModel>(
            configureCell: { (dataSource, table, idxPath, _) in
                let cell: PositionSummaryTableCell = table.dequeueReusableCell(withIdentifier: FundTableCell.defaultReusableId, for: idxPath) as! PositionSummaryTableCell
                cell.configureWith(value: dataSource[idxPath])
                return cell
        }, titleForHeaderInSection: { dataSource, index in
            let section = dataSource[index]
            return section.title
        })
    }
    
}

extension PositionsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0 //CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
}

extension PositionsListViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self._scrollViewDidScroll.onNext(scrollView)
    }
    
}

extension PositionsListViewController {
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(PositionSummaryTableCell.self, forCellReuseIdentifier: PositionSummaryTableCell.defaultReusableId)
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
