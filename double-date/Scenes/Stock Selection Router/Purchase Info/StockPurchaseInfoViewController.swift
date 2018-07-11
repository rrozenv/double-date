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
    
    private var sharesTextInputView: TitleTextFieldView!
    private var stockPriceView: CustomStackView<UILabel>!
    private var totalPriceView: CustomStackView<UILabel>!
    
    //MARK: - Views
    private var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupNavBar()
        navView.containerView.backgroundColor = Palette.lightGrey.color
        navBackgroundView.backgroundColor = Palette.lightGrey.color
        createViews()
    }
    
    deinit { print("StockPurchaseInfoViewController deinit") }
    
    func bindViewModel() {
        let doneTapped$ = doneButton.rx.tap.asObservable()
        viewModel.bindContinueButton(doneTapped$)
        
        let backTapped$ = navView.backButton.rx.tap.asObservable()
        viewModel.bindBackButton(backTapped$)
        
        let sharesText$ = sharesTextInputView.textField.rx.text.orEmpty.asObservable()
        viewModel.bindSharesText(sharesText$)
        
        viewModel.stock
            .drive(onNext: { [unowned self] in
                self.stockPriceView.item(at: 1).text = "\($0.latestPrice)"
            })
            .disposed(by: disposeBag)
        
        viewModel.totalPurchaseValue
            .drive(onNext: { [unowned self] in
                self.totalPriceView.item(at: 1).text = "\($0)"
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
    
    private func createViews() {
        sharesTextInputView = TitleTextFieldView()
        sharesTextInputView.configureWith(mainLabelText: "# of Shares", placeHolderText: "0.0")
        sharesTextInputView.snp.makeConstraints { $0.height.equalTo(60) }
        
        stockPriceView = CustomStackView<UILabel>(number: 2, stackViewProps: StackViewProps(axis: .horizontal, distribution: .fillEqually, spacing: 0))
        stockPriceView.item(at: 0).text = "Stock Price"
        stockPriceView.item(at: 0).textAlignment = .left
        stockPriceView.item(at: 1).textAlignment = .right
        stockPriceView.snp.makeConstraints { $0.height.equalTo(60) }
        
        totalPriceView = CustomStackView<UILabel>(number: 2, stackViewProps: StackViewProps(axis: .horizontal, distribution: .fillEqually, spacing: 0))
        totalPriceView.item(at: 0).text = "Total Price"
        totalPriceView.item(at: 0).textAlignment = .left
        totalPriceView.item(at: 1).textAlignment = .right
        totalPriceView.snp.makeConstraints { $0.height.equalTo(60) }
        
        let stackView = UIStackView(arrangedSubviews: [sharesTextInputView, stockPriceView, totalPriceView])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 2.0
       
        view.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.center.equalTo(view)
        }
    }
    
}
