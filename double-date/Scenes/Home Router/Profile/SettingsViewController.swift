//
//  SettingsViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 8/2/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxOptional

struct ProfileOption {
    let sort: Sort
    let title: String
    let iconImage: UIImage?
    
    enum Sort: String {
        case share = "Share"
        case logout = "Logout"
        
        static var list: [Sort] {
            return [.share , .logout]
        }
    }
    
    static func createOptions() -> [ProfileOption] {
        let sorts: [Sort] = [.share , .logout]
        return sorts.map { (sort) -> ProfileOption in
            switch sort {
            case .share: return ProfileOption(sort: sort, title: sort.rawValue, iconImage: nil)
            case .logout: return ProfileOption(sort: sort, title: sort.rawValue, iconImage: nil)
            }
        }
    }
}

final class UserProfileViewModel {
    
    let disposeBag = DisposeBag()
    private let _settings: Variable<[ProfileOption]>
    var didDismiss = PublishSubject<Void>()
    
    //MARK: - Init
    init() {
        self._settings = Variable(ProfileOption.createOptions())
    }
    
    //MARK: - Outputs
    var displayedSettings: Observable<[ProfileOption]> {
        return _settings.asObservable()
    }
    
    //MARK: - Inputs
    func bindDidSelectOption(_ observable: Observable<ProfileOption>) {
        observable
            .subscribe(onNext: { option in
                switch option.sort {
                case .logout:
                    let _ = MyKeychain.shared.removeAllValues()
                    NotificationCenter.default.post(name: .logout, object: nil)
                default: break
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bindDidSelectDismiss(_ observable: Observable<Void>) {
        observable
            .bind(to: didDismiss)
            .disposed(by: disposeBag)
    }
    
}

class UserProfileViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    var viewModel: UserProfileViewModel!
    
    private var opaqueButton: UIButton!
    private var tableBackgroundView: UIView!
    private var tableView: UITableView!
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.clear
        setupTableView()
        setupTableBackgroundView()
        setupOpaqueButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit { print("UserProfileViewController deinit") }
    
    func bindViewModel() {
        //MARK: - Input
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        let selectedOption$ = tableView.rx.modelSelected(ProfileOption.self).asObservable()
        viewModel.bindDidSelectOption(selectedOption$)
        
        let dismiss$ = opaqueButton.rx.tap.asObservable()
        viewModel.bindDidSelectDismiss(dismiss$)
        
        //MARK: - Output
        viewModel.displayedSettings
            .bind(to: tableView.rx.items(cellIdentifier: ProfileOptionCell.defaultReusableId, cellType: ProfileOptionCell.self)) { row, element, cell in
                cell.configureWith(value: element)
            }
            .disposed(by: disposeBag)
    }
    
}

extension UserProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
}

extension UserProfileViewController {
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(ProfileOptionCell.self, forCellReuseIdentifier: ProfileOptionCell.defaultReusableId)
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.equalTo(view)
            make.centerY.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.7)
            make.height.equalTo(CGFloat(ProfileOption.Sort.list.count) * 60.0)
        }
    }
    
    private func setupTableBackgroundView() {
        tableBackgroundView = UIView()
        tableBackgroundView.backgroundColor = UIColor.white
        tableBackgroundView.dropShadow()
        
        view.insertSubview(tableBackgroundView, belowSubview: tableView)
        tableBackgroundView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(view)
            make.width.equalTo(tableView.snp.width)
        }
    }
    
    private func setupOpaqueButton() {
        opaqueButton = UIButton()
        opaqueButton.backgroundColor = .clear
        
        view.addSubview(opaqueButton)
        opaqueButton.snp.makeConstraints { (make) in
            make.right.top.bottom.equalTo(view)
            make.left.equalTo(tableView.snp.right)
        }
    }
    
}
