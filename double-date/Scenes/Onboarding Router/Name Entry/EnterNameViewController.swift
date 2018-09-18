//
//  EnterNameViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/16/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SnapKit

class EnterNameViewController: UIViewController, BindableType, CustomNavBarViewable, PageIndicatable {

    let disposeBag = DisposeBag()
    var viewModel: EnterNameViewModel!
    
    var navView: BackButtonNavView = BackButtonNavView.blackArrow
    var navBackgroundView: UIView = UIView()
    var pageIndicatorView: PageIndicatorView = PageIndicatorView()
    
    private var mainLabel: UILabel!
    private var initalInvestmentFormView: CurrencyTextField!
    private var textField: StyledTextField!
    private var nextButton: UIButton!
    private var containerStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Palette.faintGrey.color
        setupNavBar()
        setupMainLabel()
        setupNextButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.nextButton.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.nextButton.isHidden = true
        switch viewModel.nameType {
        case .currenyAmount: initalInvestmentFormView.resignFirstResponder()
        case .gameName, .userName: textField.textField.resignFirstResponder()
        }
    }
    
    override var inputAccessoryView: UIView? { get { return nextButton } }
    override var canBecomeFirstResponder: Bool { return true }
    
    deinit { print("EnterNameViewController deinit") }
    
    func bindViewModel() {
        let backTapped$ = navView.backButton.rx.tap.asObservable()
        viewModel.bindBackButton(backTapped$)
        
        viewModel.pageIndicatorInfo
            .drive(onNext: { [unowned self] in
                self.setupPageIndicator(totalPageCount: $0.total, currentPage: $0.current, widthHeight: 6.0, selectedColor: Palette.aqua.color, unselectedColor: Palette.lightGrey.color)
            })
            .disposed(by: disposeBag)
        
        viewModel.textFieldType
            .drive(onNext: { [unowned self] in
                let nextTapped$ = self.nextButton.rx.tap.asObservable()
                switch $0 {
                case .gameName, .userName:
                    self.setupTextField(inputType: .regularText)
                    self.viewModel.bindTextEntry(self.textField.textOutput)
                    self.setupContainerStackView(subviews: [self.mainLabel, self.textField])
                    let keyboardNextTapped$ = self.textField.textField.rx.controlEvent([.editingDidEndOnExit]).asObservable()
                    self.viewModel.bindContinueButton(Observable.merge(nextTapped$, keyboardNextTapped$))
                case .currenyAmount:
                    self.setupCurrencyTextField()
                    self.viewModel.bindTextEntry(
                        self.initalInvestmentFormView.amount.asObservable()
                        .filter { $0 > 0 }
                        .map { "\($0)" }
                    )
                        self.setupContainerStackView(subviews: [self.mainLabel, self.initalInvestmentFormView])
                    let keyboardNextTapped$ = self.initalInvestmentFormView.rx.controlEvent([.editingDidEndOnExit]).asObservable()
                    self.viewModel.bindContinueButton(Observable.merge(nextTapped$, keyboardNextTapped$))
                }
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

extension EnterNameViewController {
    
    private func setupMainLabel() {
        mainLabel = UILabel().rxStyle(font: FontBook.AvenirMedium.of(size: 18), color: Palette.darkNavy.color, alignment: .left)
        mainLabel.numberOfLines = 0
    }
    
    private func setupCurrencyTextField() {
        initalInvestmentFormView = CurrencyTextField()
        initalInvestmentFormView.style(placeHolder: "$0.00", font: FontBook.AvenirMedium.of(size: 14), backColor: .clear, titleColor: Palette.darkNavy.color)
        initalInvestmentFormView.becomeFirstResponder()
    }
    
    private func setupTextField(inputType: TextFieldInputType) {
        textField = StyledTextField(style: .background, inputType: inputType, clearButton: false, alignment: .left, padding: 0.0)
        textField.styleTextField(placeHolder: "Enter Name...", placeHolderColor: Palette.lightBlue.color, font: FontBook.AvenirMedium.of(size: 14), backColor: .clear, titleColor: Palette.darkNavy.color, keyboardType: .default, returnKeyType: .done)
        textField.layer.cornerRadius = 2.0
        textField.layer.masksToBounds = true
        textField.showKeyboard()
    }
    
    private func setupNextButton() {
        nextButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 54)).rxStyle(title: "Next", font: FontBook.AvenirHeavy.of(size: 13), backColor: Palette.aqua.color, titleColor: .white)
    }
    
    private func setupContainerStackView(subviews: [UIView]) {
        containerStackView = UIStackView(arrangedSubviews: subviews)
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
