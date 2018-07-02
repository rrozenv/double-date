//
//  ProfileViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/24/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift

final class ProfileViewController: UIViewController, BindableType {
    
    //MARK: - Properties
    let disposeBag = DisposeBag()
    var viewModel: ProfileViewModel!
    
    //MARK: - Views
    private var logoutButton: UIButton!
    private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!
    private var initalLoadTrigger = PublishSubject<Void>()
    private var didAppearOnce = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        createLogoutButton()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !didAppearOnce else { return }
        didAppearOnce = true
        initalLoadTrigger.onNext(())
    }
    
    deinit { print("ProfileViewController deinit") }
    
    func bindViewModel() {
        let logoutTapped$ = logoutButton.rx.tap.asObservable()
        viewModel.bindLogoutButton(logoutTapped$)
        
        let refreshControl$ = refreshControl.rx.controlEvent(.valueChanged).map { _ in () }
        let fetchPositions$ = Observable.of(initalLoadTrigger.asObservable(), refreshControl$).merge().share()
        viewModel.bindFetchPositions(fetchPositions$)
        
        //MARK: - Output
        viewModel.positions
            .drive(tableView.rx.items(cellIdentifier: FundTableCell.defaultReusableId, cellType: FundTableCell.self)) { row, element, cell in
                cell.configureWith(value: element)
            }
            .disposed(by: disposeBag)
        
        viewModel.positions
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

extension ProfileViewController {
    
    private func createLogoutButton() {
        logoutButton = UIButton().rxStyle(title: "Logout", font: FontBook.AvenirMedium.of(size: 14), backColor: Palette.aqua.color, titleColor: .white)
        
        view.addSubview(logoutButton)
        logoutButton.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(view).inset(20)
            make.height.equalTo(56)
        }
    }
    
}


extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
}

extension ProfileViewController {
    
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
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(logoutButton.snp.bottom).offset(20)
        }
        
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
    }
    
}
