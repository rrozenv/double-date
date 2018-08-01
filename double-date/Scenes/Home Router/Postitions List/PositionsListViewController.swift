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
    private var emptyView: EmptyLabelsView!
    private var refreshControl: UIRefreshControl!
    
    private var initalLoadTrigger = PublishSubject<Void>()
    private var didAppearOnce = false
    private var dataSource: RxTableViewSectionedReloadDataSource<PositionListMultipleSectionModel>!
    
    var _scrollViewDidScroll = PublishSubject<UIScrollView>()
    var _shouldClosePosition = PublishSubject<Position>()
    var _shouldFetchUpdatedFund = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.appBackground.color
        setupTableView()
        setupEmptyView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !didAppearOnce else { return }
        didAppearOnce = true
        initalLoadTrigger.onNext(())
    }
    
    deinit { print("PositionsListViewController deinit") }
    
    func bindViewModel() {
        let closePosition$ = _shouldClosePosition.asObservable()
        viewModel.bindClosePosition(closePosition$)
        
        let newPositionAdded$ = NotificationCenter.default.rx.notification(Notification.Name.newPositionAdded).asObservable().mapToVoid()
        let fetchUpdatedFund$ = _shouldFetchUpdatedFund.asObservable()
        let refreshControl$ = refreshControl.rx.controlEvent(.valueChanged).map { _ in () }
        viewModel.bindFetchUpdatedFund(Observable.merge(newPositionAdded$, fetchUpdatedFund$, refreshControl$))
        
        tableView.rx.modelSelected(Position.self).asObservable()
            .filter { $0.status == .open }
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
        dataSource = PositionsListViewController.dataSource()
        let sections$ = viewModel.sections.share()
        
        sections$
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        sections$
            .map { $0.isNotEmpty }
            .bind(to: emptyView.rx.isHidden)
            .disposed(by: disposeBag)
        
        sections$.asDriverOnErrorJustComplete()
            .map { _ in false }
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        viewModel.displayDidClosePositionAlert
            .drive(onNext: { [unowned self] pos in
                let alertVc = AlertViewController(alertInfo: AlertViewController.AlertInfo.closePositionConfirmation(position: pos), okAction: nil)
                self._shouldFetchUpdatedFund.onNext(())
                self.displayAlert(vc: alertVc)
            })
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
                let cell: PositionSummaryTableCell = table.dequeueReusableCell(withIdentifier: PositionSummaryTableCell.defaultReusableId, for: idxPath) as! PositionSummaryTableCell
                cell.configureWith(value: dataSource[idxPath])
                return cell
        })
    }

}

extension PositionsListViewController: UITableViewDelegate {
    
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
        tableView.separatorStyle = .none
        tableView.backgroundColor = Palette.appBackground.color
        tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
    }
    
    private func setupEmptyView() {
        emptyView = EmptyLabelsView()
        emptyView.populateInfoWith(title: "No Positions", body: "Add a new position by tapping the search button in the top right.")
        
        view.addSubview(emptyView)
        emptyView.snp.makeConstraints { (make) in
            make.center.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.6)
        }
    }
    
}
