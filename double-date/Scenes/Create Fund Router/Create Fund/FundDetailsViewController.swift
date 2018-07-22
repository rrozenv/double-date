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
    private var datePicker = UIDatePicker()
    private let shouldDisplayDatePicker = Variable(false)
    var dataSource: RxTableViewSectionedReloadDataSource<FundDetailsMultipleSectionModel>!
    var isStartDatePickerHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        createContinueButton()
    }
    
    deinit { print("FundDetailsViewController deinit") }
    
    func bindViewModel() {
        //MARK: - Input
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        let continueTapped$ = continueButton.rx.tap.asObservable()
        viewModel.bindContinueButton(continueTapped$)
        
        //MARK: - Output
        dataSource = RxTableViewSectionedReloadDataSource<FundDetailsMultipleSectionModel>(configureCell: { [weak self] ds, tv, ip, item in
            switch ds[ip] {
            case .nameSectionItem(let props),
                 .maxCashBalanceSectionItem(let props),
                 .maxPlayersSectionItem(let props):
                let cell = tv.dequeueReusableCell(withIdentifier: TextFieldTableCell.defaultReusableId, for: ip) as! TextFieldTableCell
                cell.configureWith(value: props)
                cell.textField.rx.text.orEmpty.asObservable()
                    .filter { $0 != "" }
                    .subscribe(onNext: { (text) in
                        self?.viewModel.bindTextEntry(text: text, type: item)
                    })
                    .disposed(by: cell.disposeBag)
                return cell
            case .startDateSectionItem(let props):
                let cell = DatePickerTableCell(style: .default, reuseIdentifier: DatePickerTableCell.defaultReusableId)
//                let cell = tv.dequeueReusableCell(withIdentifier: DatePickerTableCell.defaultReusableId, for: ip) as! DatePickerTableCell
                cell.configureWith(value: props)
                cell.datePicker.rx.date.asObservable()
                    .subscribe(onNext: { [weak cell] date in
                        cell?.displayedDateButton.setTitle("\(date)", for: .normal)
                        self?.viewModel.bindDateEntry(date: date, type: item)
                    })
                    .disposed(by: cell.disposeBag)
                cell.displayedDateButton.rx.tap.asObservable()
                    .subscribe(onNext: { [weak self, weak cell] in
                        guard let sSelf = self else { return }
                        print(sSelf.isStartDatePickerHidden)
                        sSelf.isStartDatePickerHidden = !sSelf.isStartDatePickerHidden
                        cell?.datePicker.isHidden = !sSelf.isStartDatePickerHidden
                        sSelf.tableView.reloadSections([ip.section], animationStyle: .none)
                    })
                    .disposed(by: cell.disposeBag)
//                cell.reload.asObservable()
//                    .subscribe(onNext: {
//                        self?.tableView.reloadSections([ip.section], animationStyle: .none)
//                    })
//                    .disposed(by: cell.disposeBag)
//                cell.reload.asObservable()
//                    .subscribe(onNext: {
//                        self?.tableView.reloadData()
//                    })
//                    .disposed(by: cell.disposeBag)
                return cell
            }
        })
        
        viewModel.sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
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
        tableView.register(DatePickerTableCell.self, forCellReuseIdentifier: DatePickerTableCell.defaultReusableId)
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
    
    private func setupDatePicker() {
        datePicker.isHidden = true
        view.addSubview(datePicker)
        datePicker.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
        }
    }
    
}
