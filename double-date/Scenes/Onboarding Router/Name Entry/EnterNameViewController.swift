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

class EnterNameViewController<ViewModel: TextEntryable>: UIViewController, BindableType, CustomNavBarViewable, KeyboardAvoidable {
    
    private var mainLabel: UILabel!
    private var textField: StyledTextField!
    private var nextButton: UIButton!
    private var containerStackView: UIStackView!
    var navView: BackButtonNavView = BackButtonNavView.blackArrow
    var navBackgroundView: UIView = UIView()
    var adjustableConstraint: Constraint!
    var latestKeyboardHeight: CGFloat = 0
    
    let disposeBag = DisposeBag()
    var viewModel: ViewModel!
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .white
        //resignKeyboardOnViewTouch()
        setupNavBar()
//        navView.containerView.backgroundColor = Palette.lightGrey.color
//        navBackgroundView.backgroundColor = Palette.lightGrey.color
        setupMainLabel()
        setupTextField()
        setupNextButton()
        setupContainerStackView()
        bindKeyboardNotifications(bottomOffset: 100)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.textField.becomeFirstResponder()
    }
    
    deinit { print("EnterNameViewController deinit") }
    
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
        
        viewModel.isNextButtonEnabled
            .drive(onNext: { [unowned self] in
                self.textField.clearButton.isHidden = $0 ? false : true
                self.nextButton.isEnabled = $0
                self.nextButton.backgroundColor = $0 ? Palette.aqua.color : Palette.faintGrey.color
            })
            .disposed(by: disposeBag)
        
        viewModel.titleHeaderText
            .drive(onNext: { [unowned self] in
                self.mainLabel.text = $0.originalText
                self.mainLabel.varyingFonts(info: $0)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupMainLabel() {
        mainLabel = UILabel()
    }
    
    private func setupTextField() {
        textField = StyledTextField(style: .underline, inputType: .regularText, alignment: .left, padding: 20.0)
        textField.textField.style(placeHolder: "Enter Name", font: FontBook.AvenirMedium.of(size: 14), backColor: .white, titleColor: .black)
    }
    
    private func setupNextButton() {
        nextButton = UIButton().rxStyle(title: "Next", font: FontBook.AvenirHeavy.of(size: 14), backColor: .black, titleColor: .white)
        nextButton.snp.makeConstraints {
            $0.height.equalTo(60.0)
        }
    }
    
    private func setupContainerStackView() {
        containerStackView = UIStackView(arrangedSubviews: [mainLabel, textField, nextButton])
        containerStackView.axis = .vertical
        containerStackView.distribution = .equalSpacing
        containerStackView.spacing = 30.0
        
        self.view.addSubview(containerStackView)
        containerStackView.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(26.0)
            make.right.equalTo(view).offset(-26.0)
            self.adjustableConstraint = make.bottom.equalTo(view).offset(-100).constraint
        }
    }
    
}
