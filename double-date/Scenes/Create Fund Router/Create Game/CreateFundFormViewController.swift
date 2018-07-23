//
//  CreateFundFormViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/23/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional

class CreateFundFormViewController: UIViewController, CustomNavBarViewable, BindableType {
    
    let disposeBag = DisposeBag()
    var viewModel: CreateFundFormViewModel!
    var navView: BackButtonNavView = BackButtonNavView.blackArrow
    var navBackgroundView: UIView = UIView()
    private var nameFormView: TextFieldFormView!
    private var initalInvestmentFormView: TextFieldFormView!
    private var currencyTextField: CurrencyTextField!
    private var maxPlayersFormView: TextFieldFormView!
    private var startDateFormView: DatePickerFormView!
    private var endDateFormView: DatePickerFormView!
    private var datePicker = UIDatePicker()
    private var continueButton: UIButton!
    
    private var isStartDatePickerHidden = true
    private var isEndDatePickerHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavBar()
        setupForm()
        createContinueButton()
        setupDatePicker()
    }
    
    deinit { print("CreateFundFormViewController deinit") }
    
    func bindViewModel() {
        
        //MARK: - Inputs
        let continueTapped$ = continueButton.rx.tap.asObservable()
        viewModel.bindContinueButton(continueTapped$)
        
        let backTapped$ = navView.backButton.rx.tap.asObservable()
        viewModel.bindBackButton(backTapped$)
        
        let nameTextInput$ = nameFormView.textField.rx.text.orEmpty.asObservable().filterEmpty()
        //let initalInvTextInput$ = initalInvestmentFormView.textField.rx.text.orEmpty.asObservable().filterEmpty()
        let currencyTextInput$ = currencyTextField.amount.asObservable().map { String($0) }
        //let maxPlayersTextInput$ = initalInvestmentFormView.textField.rx.text.orEmpty.asObservable().filterEmpty()
        let startDateTextInput$ = datePicker.rx.date.asObservable()
            .filter { [unowned self] _ in !self.isStartDatePickerHidden }
        let endDateTextInput$ = datePicker.rx.date.asObservable()
            .filter { [unowned self] _ in !self.isEndDatePickerHidden }
        viewModel.bindTextEntry(nameTextInput$, type: .name)
        viewModel.bindTextEntry(currencyTextInput$, type: .maxCashBalance)
        //viewModel.bindTextEntry(maxPlayersTextInput$, type: .maxPlayers)
        viewModel.bindDateEntry(startDateTextInput$, type: .startDate)
        viewModel.bindDateEntry(endDateTextInput$, type: .endDate)
        
        //MARK: - Outputs
        viewModel.selectedDates
            .drive(onNext: { [unowned self] in
                self.startDateFormView.displayedDateButton.setTitle($0.start, for: .normal)
                self.endDateFormView.displayedDateButton.setTitle($0.end, for: .normal)
            })
            .disposed(by: disposeBag)
        
        viewModel.isNextButtonEnabled
            .drive(onNext: { [unowned self] in
                self.continueButton.alpha = $0 ? 1.0 : 0.5
                self.continueButton.isEnabled = $0
            })
            .disposed(by: disposeBag)
        
//        viewModel.formattedMaxCashBalance
//            .drive(initalInvestmentFormView.textField.rx.text)
//            .disposed(by: disposeBag)
        
        //MARK: - View Updates
        startDateFormView.displayedDateButton.rx.tap.asObservable()
            .subscribe(onNext: { [unowned self] in
                self.resignFirstResponder()
                self.isStartDatePickerHidden = !self.isStartDatePickerHidden
                self.datePicker.isHidden = self.isStartDatePickerHidden
            })
            .disposed(by: disposeBag)
        
        endDateFormView.displayedDateButton.rx.tap.asObservable()
            .subscribe(onNext: { [unowned self] in
                self.resignFirstResponder()
                self.isEndDatePickerHidden = !self.isEndDatePickerHidden
                self.datePicker.isHidden = self.isEndDatePickerHidden
            })
            .disposed(by: disposeBag)
        
        UIDevice.keyboardHeightWillChange
            .subscribe(onNext: { [unowned self] height in
                self.isStartDatePickerHidden = true
                self.isEndDatePickerHidden = true
            })
            .disposed(by: disposeBag)
    }
    
}


extension CreateFundFormViewController {
    
    private func setupForm() {
        nameFormView = TextFieldFormView()
        nameFormView.configureWith(value: TextFieldTableCellProps(title: "Game Name", keyBoardType: .default, placeHolderText: "Enter Name..."))
        initalInvestmentFormView = TextFieldFormView()
        initalInvestmentFormView.configureWith(value: TextFieldTableCellProps(title: "Stating Capital", keyBoardType: .decimalPad, placeHolderText: "Enter Amount..."))
        maxPlayersFormView = TextFieldFormView()
        maxPlayersFormView.configureWith(value: TextFieldTableCellProps(title: "Max Players", keyBoardType: .decimalPad, placeHolderText: "Enter Player Amount..."))
        startDateFormView = DatePickerFormView()
        startDateFormView.configureWith(value: DatePickerTableCellProps(title: "Start Date", startDate: Date()))
        endDateFormView = DatePickerFormView()
        endDateFormView.configureWith(value: DatePickerTableCellProps(title: "End Date", startDate: Date()))
        
        currencyTextField = CurrencyTextField()
        //currencyTextField.snp.makeConstraints { $0.height.equalTo(60) }
        
        let sv = UIStackView(arrangedSubviews: [nameFormView,
                                                currencyTextField,
                                                startDateFormView,
                                                endDateFormView])
        sv.axis = .vertical
        sv.distribution = .fillProportionally
        
        view.addSubview(sv)
        sv.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(navView.snp.bottom)
            make.width.equalTo(view).multipliedBy(0.9)
        }
    }
    
    private func setupDatePicker() {
        datePicker.isHidden = isStartDatePickerHidden
        datePicker.backgroundColor = .white
        datePicker.datePickerMode = .date
        
        view.addSubview(datePicker)
        datePicker.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
        }
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
