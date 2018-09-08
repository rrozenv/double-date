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
    
    private var textFieldsStackView: UIStackView!
    private var dayTextField: StyledTextField!
    private var monthTextField: StyledTextField!
    private var yearTextField: StyledTextField!
    private var firstDividerView: UIView!
    private var secondDividerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Palette.faintGrey.color
        setupNavBar()
        setupPageIndicator(totalPageCount: 3, currentPage: 0)
        setupMainLabel()
        setupTextField()
        setupNextButton()
    }
    
    deinit { print("EnterDateViewController deinit") }
    
    func bindViewModel() {
        //MARK: - Input
        let backTapped$ = navView.backButton.rx.tap.asObservable()
        viewModel.bindBackButton(backTapped$)
        
        monthTextField.textField.rx.controlEvent(.editingChanged)
            .withLatestFrom(monthTextField.textOutput)
            .scan("") { (prev, new) in new.count > 2 ? prev : new }
            .subscribe(onNext: { [unowned self] in
                self.viewModel.monthText.value = $0
                self.monthTextField.textField.text = $0
                if $0.count == 2 { self.dayTextField.textField.becomeFirstResponder() ; return }
            })
            .disposed(by: disposeBag)
        
        dayTextField.textField.rx.controlEvent(.editingChanged)
            .withLatestFrom(dayTextField.textOutput)
            .scan("") { (prev, new) in new.count > 2 ? prev : new }
            .subscribe(onNext: { [unowned self] in
                self.viewModel.dayText.value = $0
                self.dayTextField.textField.text = $0
                if $0.count == 2 { self.yearTextField.textField.becomeFirstResponder() ; return }
            })
            .disposed(by: disposeBag)
        
        yearTextField.textField.rx.controlEvent(.editingChanged)
            .withLatestFrom(yearTextField.textOutput)
            .scan("") { (prev, new) in new.count > 4 ? prev : new }
            .subscribe(onNext: { [unowned self] in
                self.yearTextField.textField.text = $0
                self.viewModel.yearText.value = $0
            })
            .disposed(by: disposeBag)

        let nextTapped$ = nextButton.rx.tap.asObservable()
        let keyboardNextTapped$ = yearTextField.textField.rx.controlEvent([.editingDidEndOnExit]).asObservable()
        viewModel.bindContinueButton(Observable.merge(nextTapped$, keyboardNextTapped$))
        
        //MARK: - Output
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
        
        view.addSubview(mainLabel)
        mainLabel.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(26.0)
            make.right.equalTo(view).offset(-26.0)
            make.top.equalTo(navView.snp.bottom).offset(20)
        }
    }
    
    private func setupTextField() {
        firstDividerView = UIView()
        configureDivider(view: firstDividerView)
        secondDividerView = UIView()
        configureDivider(view: secondDividerView)
        
        monthTextField = StyledTextField(style: .background, inputType: .regularText, clearButton: false, alignment: .left, padding: 0.0, height: 28.0)
        monthTextField.styleTextField(placeHolder: "MM", placeHolderColor: Palette.lightBlue.color, font: FontBook.AvenirMedium.of(size: 16), backColor: .clear, titleColor: Palette.darkNavy.color, keyboardType: .numberPad, returnKeyType: .done)
        
        dayTextField = StyledTextField(style: .background, inputType: .regularText, clearButton: false, alignment: .left, padding: 0.0, height: 28.0)
        dayTextField.styleTextField(placeHolder: "DD", placeHolderColor: Palette.lightBlue.color, font: FontBook.AvenirMedium.of(size: 16), backColor: .clear, titleColor: Palette.darkNavy.color, keyboardType: .numberPad, returnKeyType: .done)
        
        yearTextField = StyledTextField(style: .background, inputType: .regularText, clearButton: false, alignment: .left, padding: 0.0, height: 28.0)
        yearTextField.styleTextField(placeHolder: "YYYY", placeHolderColor: Palette.lightBlue.color, font: FontBook.AvenirMedium.of(size: 16), backColor: .clear, titleColor: Palette.darkNavy.color, keyboardType: .numberPad, returnKeyType: .done)
        
        textFieldsStackView = UIStackView(arrangedSubviews: [monthTextField, firstDividerView, dayTextField, secondDividerView, yearTextField])
        textFieldsStackView.axis = .horizontal
        textFieldsStackView.spacing = 22.0
        
        view.addSubview(textFieldsStackView)
        textFieldsStackView.snp.makeConstraints { (make) in
            make.top.equalTo(mainLabel.snp.bottom).offset(30)
            make.left.equalTo(view).offset(26)
        }
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
    
    private func configureDivider(view: UIView) {
        view.backgroundColor = Palette.lightGrey.color
        view.snp.makeConstraints { make in
            make.width.equalTo(2)
        }
    }
    
}
