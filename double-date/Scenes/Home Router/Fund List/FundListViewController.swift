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

class FundListViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    var viewModel: FundListViewModel!
    private var continueButton: UIButton!
    private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        createContinueButton()
    }
    
    deinit { print("FundListViewController deinit") }
    
    func bindViewModel() {
        //MARK: - Input
        let createTapped$ = continueButton.rx.tap.asObservable()
        viewModel.bindCreateFund(createTapped$)
        
        //MARK: - Output
        viewModel.funds
            .drive(tableView.rx.items(cellIdentifier: "FundListCell", cellType: UITableViewCell.self)) { row, element, cell in
                cell.textLabel?.text = element.name
            }
            .disposed(by: disposeBag)
    }
    
    private func toCreateFundRouter() {
        let navVc = UINavigationController()
        let router = CreateFundRouter()
        router.newFund.asObservable()
            .filterNil()
            .bind(to: viewModel.bindNewFund)
        
        navigationController?.present(navVc, animated: true, completion: nil)
    }
    
    private func createContinueButton() {
        continueButton = UIButton().rxStyle(title: "+", font: FontBook.AvenirMedium.of(size: 14), backColor: Palette.aqua.color, titleColor: .white)
        
        view.addSubview(continueButton)
        continueButton.snp.makeConstraints { (make) in
            make.right.equalTo(view).offset(-20)
            make.top.equalTo(view).offset(40)
            make.height.width.equalTo(56)
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FundListCell")
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
    }
    
}
