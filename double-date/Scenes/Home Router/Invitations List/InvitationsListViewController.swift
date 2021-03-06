//
//  InvitationsListViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/15/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift

final class InvitationsListViewController: UIViewController, CustomNavBarViewable, BindableType {
    
    //MARK: - Properties
    let disposeBag = DisposeBag()
    var viewModel: InvitationsListViewModel!
    
    //MARK: - Views
    var navView = UIView()
    var navBackgroundView: UIView = UIView()
    private var logoutButton: UIButton!
    private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!
    private var initalLoadTrigger = PublishSubject<Void>()
    private var _inviteResult = PublishSubject<(invite: Invitation, status: InvitationStatus)>()
    private var didAppearOnce = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.appBackground.color
        setupNavBar()
        navView.backgroundColor = Palette.appBackground.color
        navBackgroundView.backgroundColor = Palette.appBackground.color
        setTitleLabel(UILabel(title: "INVITATIONS").rxStyle(font: FontBook.AvenirHeavy.of(size: 11), color: Palette.lightBlue.color))
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
        let fetchInvites$ = Observable.of(initalLoadTrigger.asObservable(), refreshControl$).merge().share()
        viewModel.bindFetchInvites(fetchInvites$)
        
        let inviteResult$ = _inviteResult.asObservable()
        viewModel.bindSelectedInvite(inviteResult$)
        
        tableView.rx.modelSelected(Invitation.self).asObservable()
            .subscribe(onNext: { [unowned self] (invite) in
                let alertVc = AlertViewController(alertInfo: AlertViewController.AlertInfo.acceptInvitation(invite: invite), okAction: {
                    self._inviteResult.onNext((invite: invite, status: .accepted))
                }, cancelAction: {
                    self._inviteResult.onNext((invite: invite, status: .rejected))
                })
                self.displayAlert(vc: alertVc)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        //MARK: - Output
        viewModel.invitations
            .drive(tableView.rx.items(cellIdentifier: InvitationTableCell.defaultReusableId, cellType: InvitationTableCell.self)) { row, element, cell in
                cell.configureWith(value: element)
            }
            .disposed(by: disposeBag)
        
        viewModel.invitations
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

extension InvitationsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
}

extension InvitationsListViewController {
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(InvitationTableCell.self, forCellReuseIdentifier: InvitationTableCell.defaultReusableId)
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = Palette.appBackground.color
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(navView.snp.bottom)
        }
        
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
    }
    
}
