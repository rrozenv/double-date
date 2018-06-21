//
//  FundDetailsViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/20/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional
import RxDataSources

class FundDetailsViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    var viewModel: FundDetailsViewModel!
    private var continueButton: UIButton!
    private var tableView: UITableView!
    lazy var dataSource = RxTableViewSectionedReloadDataSource<FundDetailSection>(configureCell: { [weak self] ds, tv, ip, item in
        guard let cell = tv.dequeueReusableCell(withIdentifier: TextFieldTableCell.defaultReusableId, for: ip) as? TextFieldTableCell else { fatalError() }
        cell.configureWith(value: item.title)
        cell.textField.rx.text.orEmpty.asObservable()
            .map { text in
                switch item {
                case .name(_):
                    return FundDetailType.name(text)
                case .maxPlayers(_):
                    return FundDetailType.maxPlayers(text)
                }
            }
            .subscribe(onNext: { type in
                self?.viewModel.bindTextEntry(textType: type)
            })
            .disposed(by: cell.disposeBag)
        return cell
    })
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.red
        setupTableView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createContinueButton()
    }
    
    deinit { print("GameSettingsViewController deinit") }
    
    func bindViewModel() {
        //MARK: - Input
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        let continueTapped$ = continueButton.rx.tap.asObservable()
        viewModel.bindContinueButton(continueTapped$)
        
        //MARK: - Output
        viewModel.tableSections
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.isNextButtonEnabled
            .drive(onNext: { [unowned self] in
                self.continueButton.alpha = $0 ? 1.0 : 0.5
                self.continueButton.isEnabled = $0
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

extension FundDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
}

extension FundDetailsViewController {
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(TextFieldTableCell.self, forCellReuseIdentifier: TextFieldTableCell.defaultReusableId)
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
