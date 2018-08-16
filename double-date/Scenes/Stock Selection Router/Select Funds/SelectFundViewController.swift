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

class SelectFundViewController: UIViewController, BindableType, CustomNavBarViewable {

    let disposeBag = DisposeBag()
    var viewModel: SelectFundViewModel!
    var navView: BackButtonNavView = BackButtonNavView.blackArrow
    var navBackgroundView: UIView = UIView()
    private var navViewLabels: CustomStackView<UILabel>!
    private var mainLabel: UILabel!
    private var continueButton: UIButton!
    private var tableView: UITableView!
    private var opaqueBackgroundButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavBar()
        setupNavLabels()
        setupMainLabel()
        setupTableView()
        setupContinueButton()
    }
    
    deinit { print("SelectFundViewController deinit") }
    
    func bindViewModel() {
        //MARK: - Input
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        let doneTapped$ = continueButton.rx.tap.asObservable()
        viewModel.bindContinueButton(doneTapped$)
        
        let fundTapped$ = tableView.rx.modelSelected(FundViewModel.self).asObservable()
        viewModel.bindSelectedFund(fundTapped$)
        
        let backTapped$ = navView.backButton.rx.tap.asObservable()
        viewModel.bindBackButton(backTapped$)
        
        //MARK: - Output
        viewModel.funds
            .drive(tableView.rx.items(cellIdentifier: SelectFundTableCell.defaultReusableId, cellType: SelectFundTableCell.self)) { row, element, cell in
                cell.configureWith(value: element)
            }
            .disposed(by: disposeBag)
        
        viewModel.stock
            .drive(onNext: { [unowned self] in
                self.navViewLabels.item(at: 0).text = $0.quote.symbol
                self.navViewLabels.item(at: 1).text = $0.quote.latestPrice.asCurreny
            })
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
        return 60.0
    }
    
}

extension SelectFundViewController {
    
    private func setupNavLabels() {
        navViewLabels = CustomStackView<UILabel>(number: 2, stackViewProps: StackViewProps(axis: .vertical, distribution: .equalSpacing, spacing: 1.0))
        navViewLabels.item(at: 0).style(font: FontBook.AvenirHeavy.of(size: 13), color: Palette.darkNavy.color, alignment: .center)
        navViewLabels.item(at: 1).style(font: FontBook.AvenirMedium.of(size: 11), color: Palette.darkNavy.color, alignment: .center)

        view.addSubview(navViewLabels)
        navViewLabels.snp.makeConstraints { (make) in
            make.center.equalTo(navView)
        }
    }
    
    private func setupMainLabel() {
        mainLabel = UILabel(title: "Which funds would you \nlike to open a position in?")
            .rxStyle(font: FontBook.AvenirMedium.of(size: 18), color: Palette.darkNavy.color, alignment: .left)
        mainLabel.numberOfLines = 0
        
        view.addSubview(mainLabel)
        mainLabel.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(26)
            make.top.equalTo(navView.snp.bottom).offset(10)
        }
    }
    
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
        tableView.register(SelectFundTableCell.self, forCellReuseIdentifier: SelectFundTableCell.defaultReusableId)
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(view)
            make.top.equalTo(mainLabel.snp.bottom).offset(15)
        }
    }
    
    private func setupContinueButton() {
        continueButton = UIButton().rxStyle(title: "Done", font: FontBook.AvenirMedium.of(size: 14), backColor: Palette.aqua.color, titleColor: .white)
        
        view.addSubview(continueButton)
        continueButton.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(view)
            make.height.equalTo(60)
        }
    }
    
}
