//
//  SelectFundViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/29/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional

class SelectFundViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    var viewModel: SelectFundViewModel!
    private var continueButton: UIButton!
    private var tableView: UITableView!
    private var opaqueBackgroundButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundButton()
        setupTableView()
        setupContinueButton()
    }
    
    deinit { print("SelectFundViewController deinit") }
    
    func bindViewModel() {
        //MARK: - Input
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        let doneTapped$ = continueButton.rx.tap.asObservable()
        viewModel.bindCreateFund(doneTapped$)
        
        let fundTapped$ = tableView.rx.modelSelected(FundViewModel.self).asObservable()
        viewModel.bindSelectedFund(fundTapped$)
        
        opaqueBackgroundButton.rx.tap.asObservable()
            .subscribe(onNext: { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        //MARK: - Output
        viewModel.funds
            .do(onNext: { [unowned self] in
                let tableHeight = (CGFloat($0.count) * 70.0) + 70.0
                self.tableView.snp.updateConstraints { make in make.height.equalTo(tableHeight) }
            })
            .drive(tableView.rx.items(cellIdentifier: UserContactTableCell.defaultReusableId, cellType: UserContactTableCell.self)) { row, element, cell in
                cell.configureWith(value: element)
            }
            .disposed(by: disposeBag)
        
        viewModel.isDoneButtonEnabled
            .drive(onNext: { [unowned self] in
                self.continueButton.isEnabled = $0
                self.continueButton.alpha = $0 ? 1.0 : 0.5
            })
            .disposed(by: disposeBag)
    }
    
}

extension SelectFundViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return continueButton
    }
    
}

extension SelectFundViewController {
    
    private func setupBackgroundButton() {
        opaqueBackgroundButton = UIButton()
        opaqueBackgroundButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        view.addSubview(opaqueBackgroundButton)
        opaqueBackgroundButton.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(UserContactTableCell.self, forCellReuseIdentifier: UserContactTableCell.defaultReusableId)
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = UIColor.white
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.width.equalTo(view).multipliedBy(0.8)
            make.center.equalTo(view)
            make.height.equalTo(200)
        }
    }
    
    private func setupContinueButton() {
        continueButton = UIButton().rxStyle(title: "Done", font: FontBook.AvenirMedium.of(size: 14), backColor: Palette.aqua.color, titleColor: .white)
    }
    
}
