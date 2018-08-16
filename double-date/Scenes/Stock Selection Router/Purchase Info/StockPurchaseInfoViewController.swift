//
//  StockPurchaseInfoViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/9/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift

final class StockPurchaseInfoViewController: UIViewController, CustomNavBarViewable, BindableType {
    
    //MARK: - Properties
    let disposeBag = DisposeBag()
    var viewModel: StockPurchaseInfoViewModel!
    var navView: BackButtonNavView = BackButtonNavView.blackArrow
    var navBackgroundView: UIView = UIView()
    var stackView: CustomStackView<UILabel>!
    
    private var cashBalanceLabel: UILabel!
    private var sharesTextInputView: TitleTextFieldView!
    private var stockPriceView: CustomStackView<UILabel>!
    private var totalPriceView: CustomStackView<UILabel>!
    private var limitTextInputView: TitleTextFieldView!
    private var containerView: UIView!
    
    //MARK: - Views
    private var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupNavBar()
        setupContainerView()
        createViews()
        setupDoneButton()
        setupCashBalanceLabel()
    }
    
    deinit { print("StockPurchaseInfoViewController deinit") }
    
    func bindViewModel() {
        let doneTapped$ = doneButton.rx.tap.asObservable()
        viewModel.bindContinueButton(doneTapped$)
        
        let backTapped$ = navView.backButton.rx.tap.asObservable()
        viewModel.bindBackButton(backTapped$)
        
        let sharesText$ = sharesTextInputView.textField.rx.text.orEmpty.asObservable()
        viewModel.bindSharesText(sharesText$)
        
        let limitText$ = limitTextInputView.textField.rx.text.orEmpty.asObservable()
        viewModel.bindLimitText(limitText$)
        
        viewModel.stock
            .drive(onNext: { [unowned self] in
                self.stockPriceView.item(at: 1).text = "\($0.quote.latestPrice)"
            })
            .disposed(by: disposeBag)
        
        viewModel.totalPurchaseValue
            .drive(onNext: { [unowned self] in
                self.totalPriceView.item(at: 1).text = "\($0)"
            })
            .disposed(by: disposeBag)
        
        viewModel.portfolioCashBalance
            .drive(onNext: { [unowned self] in
                self.cashBalanceLabel.text = "Portfolio Cash Balance: $\($0)"
            })
            .disposed(by: disposeBag)
        
        viewModel.isValidPurchase
            .drive(onNext: { [unowned self] in
                self.doneButton.alpha = $0 ? 1.0 : 0.5
                self.doneButton.isEnabled = $0
            })
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .drive(onNext: {
                print("isLoading: \($0)")
            })
            .disposed(by: disposeBag)
        
        viewModel.error
            .drive(onNext: { [weak self] in
                self?.displayNetworkError($0)
            })
            .disposed(by: disposeBag)
    }
    
}

extension StockPurchaseInfoViewController {
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 2.0
        containerView.layer.masksToBounds = true
        containerView.dropShadow()
        
        view.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view).inset(26)
            make.top.equalTo(navView.snp.bottom).offset(15)
        }
    }
    
    private func setupCashBalanceLabel() {
        cashBalanceLabel = UILabel().rxStyle(font: FontBook.AvenirMedium.of(size: 14), color: .black, alignment: .center)
        
        view.addSubview(cashBalanceLabel)
        cashBalanceLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(navView.snp.bottom).offset(20)
        }
    }
    
    private func createViews() {
        sharesTextInputView = TitleTextFieldView()
        sharesTextInputView.mainLabel.style(font: FontBook.AvenirHeavy.of(size: 12), color: Palette.lightBlue.color)
        sharesTextInputView.configureWith(mainLabelText: "Shares of", placeHolderText: "0.0")
        sharesTextInputView.snp.makeConstraints { $0.height.equalTo(64) }
        
        stockPriceView = CustomStackView<UILabel>(number: 2, stackViewProps: StackViewProps(axis: .horizontal, distribution: .fillEqually, spacing: 0))
        stockPriceView.item(at: 0).style(font: FontBook.AvenirHeavy.of(size: 12), color: Palette.lightBlue.color, alignment: .left)
        stockPriceView.item(at: 1).style(font: FontBook.AvenirMedium.of(size: 15), color: Palette.darkNavy.color, alignment: .right)
        stockPriceView.item(at: 0).text = "Stock Price"
        stockPriceView.snp.makeConstraints { $0.height.equalTo(64) }
        
        totalPriceView = CustomStackView<UILabel>(number: 2, stackViewProps: StackViewProps(axis: .horizontal, distribution: .fillEqually, spacing: 0))
        totalPriceView.item(at: 0).style(font: FontBook.AvenirHeavy.of(size: 12), color: Palette.lightBlue.color, alignment: .left)
        totalPriceView.item(at: 1).style(font: FontBook.AvenirMedium.of(size: 15), color: Palette.darkNavy.color, alignment: .right)
        totalPriceView.item(at: 0).text = "Total Price"
        totalPriceView.snp.makeConstraints { $0.height.equalTo(64) }
        
        limitTextInputView = TitleTextFieldView()
        limitTextInputView.configureWith(mainLabelText: "Limit Buy (Optional)", placeHolderText: "$0.00")
        limitTextInputView.snp.makeConstraints { $0.height.equalTo(64) }
        
        let stackView = UIStackView(arrangedSubviews: [sharesTextInputView,
                                                       stockPriceView,
                                                       totalPriceView,
                                                       limitTextInputView])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 2.0
       
        containerView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(containerView)
            make.left.right.equalTo(containerView).inset(22)
        }
    }
    
    private func setupDoneButton() {
        doneButton = UIButton().rxStyle(title: "Done", font: FontBook.AvenirMedium.of(size: 14), backColor: Palette.aqua.color, titleColor: .white)
        doneButton.alpha = 0.5
        doneButton.isEnabled = false
        
        view.addSubview(doneButton)
        doneButton.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(56)
        }
    }
    
}
