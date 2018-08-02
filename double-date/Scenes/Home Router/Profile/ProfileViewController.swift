//
//  ProfileViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/24/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift

final class ProfileViewController: UIViewController, CustomNavBarViewable, BindableType {
    
    //MARK: - Properties
    let disposeBag = DisposeBag()
    var viewModel: ProfileViewModel!
    
    //MARK: - Views
    var navView = UIView()
    var navBackgroundView: UIView = UIView()
    private var logoutButton: UIButton!
    private var settingsButton: UIButton!
    private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!
    private var headerView: ProfileHeaderView!

    private var initalLoadTrigger = PublishSubject<Void>()
    private var didAppearOnce = false
    private var userProfileDisplayed = Variable(false)
    
    private lazy var userProfileViewController: UserProfileViewController = { [unowned self] in
        var vc = UserProfileViewController()
        let vm = UserProfileViewModel()
        vc.setViewModelBinding(model: vm)
        vm.didDismiss.asObservable()
            .map { false }
            .bind(to: self.userProfileDisplayed)
            .disposed(by: vm.disposeBag)
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        navView.backgroundColor = .white
        navBackgroundView.backgroundColor = .white
        setupNavBar()
        setupTableView()
        createSettingsButton()
        setupSettingsVc()
        //createLogoutButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !didAppearOnce else { return }
        didAppearOnce = true
        initalLoadTrigger.onNext(())
    }
    
    deinit { print("ProfileViewController deinit") }
    
    func bindViewModel() {
//        let logoutTapped$ = logoutButton.rx.tap.asObservable()
//        viewModel.bindLogoutButton(logoutTapped$)
        
        let refreshControl$ = refreshControl.rx.controlEvent(.valueChanged).map { _ in () }
        let fetchPositions$ = Observable.of(initalLoadTrigger.asObservable(), refreshControl$).merge().share()
        viewModel.bindFetchPositions(fetchPositions$)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        userProfileDisplayed.asObservable()
            .skip(1)
            .subscribe(onNext: { [unowned self] in
                self.toggleUserProfileVc(isDisplayed: $0)
            })
            .disposed(by: disposeBag)
        
        settingsButton.rx.tap.asObservable()
            .subscribe(onNext: { [unowned self] in
                self.userProfileDisplayed.value = !self.userProfileDisplayed.value
            })
            .disposed(by: disposeBag)
        
        //MARK: - Output
        viewModel.positions
            .drive(tableView.rx.items(cellIdentifier: PositionSummaryTableCell.defaultReusableId, cellType: PositionSummaryTableCell.self)) { row, element, cell in
                cell.configureWith(value: element, displayClosed: true)
            }
            .disposed(by: disposeBag)
        
        viewModel.positions
            .map { _ in false }
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        viewModel.user
            .drive(onNext: { [unowned self] in
                self.headerView.populateInfoWith(currentUser: $0)
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
    
    private func setupSettingsVc() {
        var vc = UserProfileViewController()
        let vm = UserProfileViewModel()
        vc.setViewModelBinding(model: vm)
        vm.didDismiss.asObservable()
            .map { false }
            .bind(to: self.userProfileDisplayed)
            .disposed(by: vm.disposeBag)
        let frame = CGRect(x: self.view.frame.origin.x - self.view.frame.size.width,
                           y: self.view.frame.origin.y,
                           width: view.frame.size.width,
                           height: view.frame.size.height)
        self.addChild(self.userProfileViewController, frame: frame, animated: false)
    }
    
    private func toggleUserProfileVc(isDisplayed: Bool) {
        if isDisplayed {
            UIView.animate(withDuration: 0.3, animations: {
                self.userProfileViewController.view.frame.origin.x += self.view.frame.size.width
                self.view.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.userProfileViewController.view.frame.origin.x -= self.view.frame.size.width
                self.view.layoutIfNeeded()
            })
        }
    }
    
}

extension ProfileViewController {
    
    private func createSettingsButton() {
        settingsButton = UIButton().rxStyle(title: "", font: FontBook.AvenirMedium.of(size: 14), backColor: Palette.aqua.color, titleColor: .white)
        
        view.addSubview(settingsButton)
        settingsButton.snp.makeConstraints { (make) in
            make.right.top.equalTo(view).inset(20)
            make.height.width.equalTo(50)
        }
    }
    
    private func settingsLogoutButton() {
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
        return 42.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        //view.backgroundColor = Palette.appBackground.color
        let label = UILabel(title: "TRADE HISTORY").rxStyle(font: FontBook.AvenirHeavy.of(size: 11), color: Palette.lightBlue.color)
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(23)
            make.centerY.equalTo(view)
        }
        return view
    }
    
}

extension ProfileViewController {
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.register(PositionSummaryTableCell.self, forCellReuseIdentifier: PositionSummaryTableCell.defaultReusableId)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = Palette.appBackground.color
        tableView.contentInsetAdjustmentBehavior = .never
        
        headerView = ProfileHeaderView()
        headerView.dropShadow()
        tableView.tableHeaderView = headerView
        headerView.snp.makeConstraints { (make) in
            make.centerX.width.top.bottom.equalTo(tableView)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(navView.snp.bottom)
        }
        
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
    }
    
}
