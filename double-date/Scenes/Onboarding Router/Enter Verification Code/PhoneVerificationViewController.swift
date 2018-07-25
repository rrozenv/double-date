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

class PhoneVerificationViewController: UIViewController, BindableType, CustomNavBarViewable, PageIndicatable, LoadingIndicatable {
    
    private var mainLabel: UILabel!
    private var textField: StyledTextField!
    private var nextButton: UIButton!
    private var containerStackView: UIStackView!
    var navView: BackButtonNavView = BackButtonNavView.blackArrow
    var navBackgroundView: UIView = UIView()
    var pageIndicatorView: PageIndicatorView = PageIndicatorView()
    var loadingView: LoadingView = LoadingView()
    
    let disposeBag = DisposeBag()
    var viewModel: PhoneVerificationViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Palette.faintGrey.color
        setupNavBar()
        setupPageIndicator(totalPageCount: 3, currentPage: 2, widthHeight: 6.0, selectedColor: Palette.aqua.color, unselectedColor: Palette.faintBlue.color)
        setupMainLabel()
        setupTextField()
        setupNextButton()
        setupContainerStackView()
        setupLoadingIndicator()
        textField.showKeyboard()
    }
    
    deinit { print("PhoneVerificationViewController deinit") }
    
    func bindViewModel() {
        let backTapped$ = navView.backButton.rx.tap.asObservable()
        viewModel.bindBackButton(backTapped$)
        
        viewModel.bindTextEntry(textField.textOutput)
        
        let nextTapped$ = nextButton.rx.tap.asObservable()
        let keyboardNextTapped$ = textField.textField.rx.controlEvent([.editingDidEndOnExit]).asObservable()
        viewModel.bindContinueButton(Observable.merge(nextTapped$, keyboardNextTapped$))
        
        viewModel.titleHeaderText
            .drive(onNext: { [unowned self] in
                self.mainLabel.text = $0
            })
            .disposed(by: disposeBag)
        
        viewModel.isCodeValid
            .drive(onNext: { [unowned self] in
                self.nextButton.isEnabled = $0
                self.nextButton.alpha = $0 ? 1.0 : 0.5
            })
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .drive(onNext: { [weak self] in
                $0 ? self?.loadingView.loadingIndicator.startAnimating() :
                    self?.loadingView.loadingIndicator.stopAnimating()
                
                self?.loadingView.isHidden = $0 ? false : true
            })
            .disposed(by: disposeBag)
        
        viewModel.error
            .drive(onNext: { [weak self] in self?.displayNetworkError($0) })
            .disposed(by: disposeBag)
    }
    
}

extension PhoneVerificationViewController {
    
    private func setupMainLabel() {
        mainLabel = UILabel().rxStyle(font: FontBook.AvenirMedium.of(size: 18), color: Palette.darkNavy.color, alignment: .left)
        mainLabel.numberOfLines = 0
    }
    
    private func setupTextField() {
        textField = StyledTextField(style: .background, inputType: .regularText, clearButton: false, alignment: .left, padding: 0.0)
        textField.styleTextField(placeHolder: "Enter 4-digit code...", placeHolderColor: Palette.lightBlue.color, font: FontBook.AvenirMedium.of(size: 14), backColor: .clear, titleColor: Palette.darkNavy.color, keyboardType: .numberPad, returnKeyType: .done)
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
