//
//  UserListViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/15/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional

class UsersViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    var viewModel: UsersViewModel!
    private var continueButton: UIButton!
    //private var tableView: UITableView!
    //let provider = MoyaProvider<API>()
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.red
        //setupTableView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createContinueButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit { print("UsersViewController deinit") }
    
    func bindViewModel() {
        //MARK: - Input
        let continueTapped$ = continueButton.rx.tap.asObservable()
        viewModel.bindContinueButton(continueTapped$)
        
        //MARK: - Output
        viewModel.user
            .drive(onNext: { user in
                print("Got user \(user)")
            })
            .disposed(by: disposeBag)
        
        viewModel.error
            .drive(onNext: { [weak self] (error) in
                self?.displayNetworkError(error)
            })
            .disposed(by: disposeBag)
    }
    
    private func createContinueButton() {
        continueButton = UIButton().rxStyle(title: "Continue", font: FontBook.AvenirMedium.of(size: 14), backColor: Palette.aqua.color, titleColor: .white)
        
        view.addSubview(continueButton)
        continueButton.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(56)
        }
    }
    
}

extension UsersViewController: UITableViewDelegate {
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return CGFloat.leastNonzeroMagnitude
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return CGFloat.leastNonzeroMagnitude
//    }
    
}

extension UsersViewController {
    
//    private func setupTableView() {
//        tableView = UITableView(frame: CGRect.zero, style: .grouped)
//        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.defaultReusableId)
//        tableView.estimatedRowHeight = 200
//        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.estimatedSectionHeaderHeight = 0
//        tableView.estimatedSectionFooterHeight = 0
//        tableView.separatorStyle = .singleLine
//        tableView.backgroundColor = UIColor.white
//
//        view.addSubview(tableView)
//        tableView.snp.makeConstraints { (make) in
//            make.edges.equalTo(view)
//        }
//    }
    
}
