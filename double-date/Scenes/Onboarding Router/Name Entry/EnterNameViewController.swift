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

class EnterNameViewController<ViewModel: TextEntryable>: UIViewController, BindableType, CustomNavBarViewable, KeyboardAvoidableTest {

    private var mainLabel: UILabel!
    private var textField: StyledTextField!
    private var nextButton: UIButton!
    private var containerStackView: UIStackView!
    var navView: BackButtonNavView = BackButtonNavView.blackArrow
    var navBackgroundView: UIView = UIView()
    var keyboardIsVisible: Bool = false
    var adjustableConstraint: NSLayoutConstraint!
    
    let disposeBag = DisposeBag()
    var viewModel: ViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupNavBar()
        setupMainLabel()
        setupTextField()
        setupNextButton()
        setupContainerStackView()
        bindKeyboardNotifications(bottomOffset: 60, initalConst: -200)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.showKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.resignFirstResponder()
        keyboardIsVisible = false
    }
 
    deinit { print("EnterNameViewController deinit") }
    
    func bindViewModel() {
        let backTapped$ = navView.backButton.rx.tap.asObservable()
            //.do(onNext: { [unowned self] in self.resignFirstResponder() })
        viewModel.bindBackButton(backTapped$)
        
        viewModel.bindTextEntry(textField.textOutput)
        
        let nextTapped$ = nextButton.rx.tap.asObservable()
        viewModel.bindContinueButton(nextTapped$)
        
        let clearTapped$ = textField.clearButton.rx.tap.asObservable()
            .do(onNext: { [unowned self] in self.textField.clearText() })
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
        textField.styleTextField(placeHolder: "Enter Name", font: FontBook.AvenirMedium.of(size: 14), backColor: .white, titleColor: .black, keyboardType: .default)
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
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26).isActive = true
        containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26).isActive = true
        self.adjustableConstraint = containerStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200)
        self.adjustableConstraint.isActive = true
        
//        containerStackView.snp.makeConstraints { (make) in
//            make.left.equalTo(view).offset(26.0)
//            make.right.equalTo(view).offset(-26.0)
//            self.adjustableConstraint = make.bottom.equalTo(view).offset(-100).constraint
//        }
    }
    
}
