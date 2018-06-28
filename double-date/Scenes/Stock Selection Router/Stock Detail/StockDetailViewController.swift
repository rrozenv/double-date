//
//  StockDetailViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/27/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift

final class StockDetailViewController: UIViewController, CustomNavBarViewable, BindableType {
  
    //MARK: - Properties
    let disposeBag = DisposeBag()
    var viewModel: StockDetailViewModel!
    var navView: BackButtonNavView = BackButtonNavView.blackArrow
    var navBackgroundView: UIView = UIView()
    var stackView: CustomStackView<UILabel>!
    
    //MARK: - Views
    private var buyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupNavBar()
        navView.containerView.backgroundColor = Palette.lightGrey.color
        navBackgroundView.backgroundColor = Palette.lightGrey.color
        createLabels()
        createLogoutButton()
    }
    
    deinit { print("StockDetailViewController deinit") }
    
    func bindViewModel() {
        let buyTapped$ = buyButton.rx.tap.asObservable()
        viewModel.bindSelectedPositionType(buyTapped$.map { PositionType.buy })
        
        let backTapped$ = navView.backButton.rx.tap.asObservable()
        viewModel.bindBackButton(backTapped$)
        
        viewModel.stock
            .drive(onNext: { [unowned self] in
                self.stackView.item(at: 0).text = $0.companyName
                self.stackView.item(at: 1).text = "\($0.latestPrice)"
                self.stackView.item(at: 2).text = "\($0.changePercent)"
            })
            .disposed(by: disposeBag)
    }
    
}

extension StockDetailViewController {
    
    private func createLabels() {
        stackView = CustomStackView<UILabel>(number: 3, stackViewProps: StackViewProps(axis: .vertical, distribution: .equalSpacing, spacing: 20))
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.center.equalTo(view)
        }
    }
    
    private func createLogoutButton() {
        buyButton = UIButton().rxStyle(title: "Buy", font: FontBook.AvenirMedium.of(size: 14), backColor: Palette.aqua.color, titleColor: .white)
        
        view.addSubview(buyButton)
        buyButton.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(56)
        }
    }
    
}
