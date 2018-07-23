//
//  PhoneVerificationViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/14/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SnapKit

class PhoneVerificationViewController: UIViewController, BindableType, CustomNavBarViewable, KeyboardAvoidable {
    
    private var textField: StyledTextField!
    private var nextButton: UIButton!
    private var containerStackView: UIStackView!
    var navView: BackButtonNavView = BackButtonNavView.blackArrow
    var navBackgroundView: UIView = UIView()
    var adjustableConstraint: Constraint!
    var latestKeyboardHeight: CGFloat = 0
    
    let disposeBag = DisposeBag()
    var viewModel: PhoneVerificationViewModel!
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .white
        setupNavBar()
//        navView.containerView.backgroundColor = Palette.lightGrey.color
//        navBackgroundView.backgroundColor = Palette.lightGrey.color
        setupTextField()
        setupNextButton()
        setupContainerStackView()
        bindKeyboardNotifications(bottomOffset: 100)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.textField.becomeFirstResponder()
    }
    
    deinit { print("PhoneVerificationViewController deinit") }
    
    func bindViewModel() {
        let backTapped$ = navView.backButton.rx.tap.asObservable()
        viewModel.bindBackButton(backTapped$)
        
        let nameText$ = textField.textField.rx.text.orEmpty.asObservable()
        viewModel.bindTextEntry(nameText$)
        
        let nextTapped$ = nextButton.rx.tap.asObservable()
        viewModel.bindContinueButton(nextTapped$)
        
        let clearTapped$ = textField.clearButton.rx.tap.asObservable()
            .do(onNext: { [unowned self] in self.textField.textField.text = nil })
        viewModel.bindClearButton(clearTapped$)
        
        viewModel.isCodeValid
            .drive(onNext: { [unowned self] in
                self.textField.clearButton.isHidden = $0 ? false : true
                self.nextButton.isEnabled = $0
                self.nextButton.backgroundColor = $0 ? .yellow : .gray
            })
            .disposed(by: disposeBag)
        
        viewModel.error
            .drive(onNext: { [weak self] in self?.displayNetworkError($0) })
            .disposed(by: disposeBag)
    }
    
    private func setupTextField() {
        textField = StyledTextField(style: .underline,
                                    inputType: .regularText,
                                    alignment: .center,
                                    padding: 0)
        textField.textField.style(placeHolder: "Enter Verification Code", font: FontBook.AvenirMedium.of(size: 14), backColor: .white, titleColor: .black)
    }
    
    private func setupNextButton() {
        nextButton = UIButton()
        nextButton.style(title: "Next")
        nextButton.snp.makeConstraints { $0.height.equalTo(60) }
    }
    
    private func setupContainerStackView() {
        containerStackView = UIStackView(arrangedSubviews: [textField, nextButton])
        containerStackView.axis = .vertical
        containerStackView.distribution = .equalSpacing
        containerStackView.spacing = 30.0
        
        self.view.addSubview(containerStackView)
        containerStackView.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(26)
            make.right.equalTo(view).offset(-26)
            self.adjustableConstraint = make.bottom.equalTo(view).offset(-100).constraint
        }
    }
    
}
