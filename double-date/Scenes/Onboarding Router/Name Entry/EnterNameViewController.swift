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
    private var textField: StyledTextField!
    private var nextButton: UIButton!
    private var containerStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Palette.faintGrey.color
        setupNavBar()
        setupPageIndicator(totalPageCount: 3, currentPage: 0, widthHeight: 6.0, selectedColor: Palette.aqua.color, unselectedColor: Palette.faintBlue.color)
        setupMainLabel()
        setupTextField()
        setupNextButton()
        setupContainerStackView()
    }
 
    deinit { print("EnterNameViewController deinit") }
    
    func bindViewModel() {
        let backTapped$ = navView.backButton.rx.tap.asObservable()
        viewModel.bindBackButton(backTapped$)
        
        viewModel.bindTextEntry(textField.textOutput)
        
        let nextTapped$ = nextButton.rx.tap.asObservable()
        let keyboardNextTapped$ = textField.textField.rx.controlEvent([.editingDidEndOnExit]).asObservable()
        viewModel.bindContinueButton(Observable.merge(nextTapped$, keyboardNextTapped$))
        
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
    
    private func setupTextField() {
        textField = StyledTextField(style: .background, inputType: .regularText, clearButton: false, alignment: .left, padding: 0.0)
        textField.styleTextField(placeHolder: "Enter Name...", placeHolderColor: Palette.lightBlue.color, font: FontBook.AvenirMedium.of(size: 14), backColor: .clear, titleColor: Palette.darkNavy.color, keyboardType: .default, returnKeyType: .done)
        textField.layer.cornerRadius = 2.0
        textField.layer.masksToBounds = true
        textField.showKeyboard()
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
                                                            textField])
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
