//
//  EnterFundNameViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 8/28/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SnapKit

class EnterDateViewController: UIViewController, BindableType, CustomNavBarViewable, PageIndicatable {
    
    let disposeBag = DisposeBag()
    var viewModel: EnterDateViewModel!
    
    var navView: BackButtonNavView = BackButtonNavView.blackArrow
    var navBackgroundView: UIView = UIView()
    var pageIndicatorView: PageIndicatorView = PageIndicatorView()
    
    private var mainLabel: UILabel!
    private var textField: StyledTextField!
    private var nextButton: UIButton!
    private var containerStackView: UIStackView!
    
    private var textFieldsStackView: UIStackView!
    private var dayTextField: UITextField!
    private var monthTextField: StyledTextField!
    private var yearTextField: StyledTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Palette.faintGrey.color
        setupNavBar()
        setupPageIndicator(totalPageCount: 3, currentPage: 0)
        setupMainLabel()
        setupTextField()
        setupNextButton()
        setupContainerStackView()
    }
    
    deinit { print("EnterFundNameViewController deinit") }
    
    func bindViewModel() {
        let backTapped$ = navView.backButton.rx.tap.asObservable()
        viewModel.bindBackButton(backTapped$)
        
        //let dayText$ = dayTextField.textOutput
//            .do(onNext: { [unowned self] in
//            if $0.count >= 2 { self.monthTextField.textField.becomeFirstResponder() }
//        })
        //viewModel.bindDayTextEntry(dayTextField.rx.text.asObservable().filterNil())
        
        dayTextField.rx.text.asObservable().filterNil()
            .subscribe(onNext: {
                guard $0.count <= 2 else { self.monthTextField.textField.becomeFirstResponder() ; return }
                self.viewModel.dayTextTest.value = $0
            })
            .disposed(by: disposeBag)
        
        dayTextField.rx.controlEvent(.editingChanged).subscribe(onNext: { [unowned self] in
            if let text = self.dayTextField.text,
                text.count >= 2 {
                self.monthTextField.textField.becomeFirstResponder()
            }
        }).disposed(by: disposeBag)
        
        let monthText$ = monthTextField.textOutput
//            .do(onNext: { [unowned self] in
//            if $0.count >= 2 { self.yearTextField.textField.becomeFirstResponder() }
//        })
        viewModel.bindMonthTextEntry(monthText$)
        
        let yearText$ = yearTextField.textOutput
//            .do(onNext: { [unowned self] in
//            if $0.count >= 4 { self.yearTextField.textField.resignFirstResponder() }
//        })
        viewModel.bindYearTextEntry(yearText$)
        
        let nextTapped$ = nextButton.rx.tap.asObservable()
        let keyboardNextTapped$ = yearTextField.textField.rx.controlEvent([.editingDidEndOnExit]).asObservable()
        viewModel.bindContinueButton(Observable.merge(nextTapped$, keyboardNextTapped$))
        
        viewModel.dayText$
            .drive(onNext: { [unowned self] in
                if $0.count >= 2 { self.monthTextField.textField.becomeFirstResponder() }
            })
            .disposed(by: disposeBag)
        
        viewModel.isNextButtonEnabled
            .drive(onNext: { [unowned self] in
                self.nextButton.isEnabled = $0
                self.nextButton.alpha = $0 ? 1.0 : 0.5
            })
            .disposed(by: disposeBag)
        
        viewModel.titleHeaderText
            .drive(onNext: { [unowned self] in
                self.mainLabel.text = $0
            })
            .disposed(by: disposeBag)
    }
    
}

extension EnterDateViewController {
    
    private func setupMainLabel() {
        mainLabel = UILabel().rxStyle(font: FontBook.AvenirMedium.of(size: 18), color: Palette.darkNavy.color, alignment: .left)
        mainLabel.numberOfLines = 0
    }
    
    private func setupTextField() {
        dayTextField = UITextField()
        dayTextField.placeholder = "DD"
//        dayTextField = StyledTextField(style: .background, inputType: .regularText, clearButton: false, alignment: .left, padding: 0.0)
//        dayTextField.styleTextField(placeHolder: "DD", placeHolderColor: Palette.lightBlue.color, font: FontBook.AvenirMedium.of(size: 14), backColor: .clear, titleColor: Palette.darkNavy.color, keyboardType: .numberPad, returnKeyType: .done)
        
        monthTextField = StyledTextField(style: .background, inputType: .regularText, clearButton: false, alignment: .left, padding: 0.0)
        monthTextField.styleTextField(placeHolder: "MM", placeHolderColor: Palette.lightBlue.color, font: FontBook.AvenirMedium.of(size: 14), backColor: .clear, titleColor: Palette.darkNavy.color, keyboardType: .numberPad, returnKeyType: .done)
        
        yearTextField = StyledTextField(style: .background, inputType: .regularText, clearButton: false, alignment: .left, padding: 0.0)
        yearTextField.styleTextField(placeHolder: "YYYY", placeHolderColor: Palette.lightBlue.color, font: FontBook.AvenirMedium.of(size: 14), backColor: .clear, titleColor: Palette.darkNavy.color, keyboardType: .numberPad, returnKeyType: .done)
        
        textFieldsStackView = UIStackView(arrangedSubviews: [dayTextField, monthTextField, yearTextField])
        textFieldsStackView.axis = .horizontal
        textFieldsStackView.spacing = 15.0
        
//        textField = StyledTextField(style: .background, inputType: .regularText, clearButton: false, alignment: .left, padding: 0.0)
//        textField.styleTextField(placeHolder: "Enter Name...", placeHolderColor: Palette.lightBlue.color, font: FontBook.AvenirMedium.of(size: 14), backColor: .clear, titleColor: Palette.darkNavy.color, keyboardType: .default, returnKeyType: .done)
//        textField.layer.cornerRadius = 2.0
//        textField.layer.masksToBounds = true
//        textField.showKeyboard()
    }
    
    private func setupNextButton() {
        nextButton = UIButton().rxStyle(title: "Next", font: FontBook.AvenirHeavy.of(size: 13), backColor: Palette.aqua.color, titleColor: .white)
        nextButton.layer.cornerRadius = 2.0
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.heightAnchor.constraint(equalToConstant: 54).isActive = true
        
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(54.0)
            make.left.right.bottom.equalTo(view)
        }
    }
    
    private func setupContainerStackView() {
        containerStackView = UIStackView(arrangedSubviews: [mainLabel,
                                                            textFieldsStackView])
        containerStackView.axis = .vertical
        containerStackView.distribution = .equalSpacing
        containerStackView.spacing = 20.0
        
        self.view.addSubview(containerStackView)
        containerStackView.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(26.0)
            make.right.equalTo(view).offset(-26.0)
            make.top.equalTo(navView.snp.bottom).offset(20)
        }
    }
    
}
