//
//  EnableNotificationsViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/20/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import UserNotifications

final class EnableNotificationsViewController: UIViewController, BindableType {
    
    //MARK: - Properties
    let disposeBag = DisposeBag()
    var viewModel: EnableNotificationsViewModel!
 
    //MARK: - Views
    private var buttonsStackView: CustomStackView<UIButton>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupButtons()
    }
    
    deinit { print("EnableNotificationsViewController deinit") }
    
    func bindViewModel() {
        let enableTapped$ = buttonsStackView.item(at: 0).rx.tap.asObservable()
        viewModel.bindEnableButton(enableTapped$)
        let skipTapped$ = buttonsStackView.item(at: 1).rx.tap.asObservable()
        viewModel.bindSkipButton(skipTapped$)
    }
    
}

extension EnableNotificationsViewController {
    
    private func setupButtons() {
        buttonsStackView = CustomStackView<UIButton>(number: 2,
                                            stackViewProps: StackViewProps(axis: .vertical, distribution: .fillEqually, spacing: 10))
        buttonsStackView.views.enumerated().forEach { index, button in
            button.style(title: index == 0 ? "Enable" : "Skip" ,
                         font: FontBook.AvenirMedium.of(size: 14),
                         backColor: .red,
                         titleColor: .white)
        }
        
        view.addSubview(buttonsStackView)
        buttonsStackView.snp.makeConstraints { (make) in
            make.width.equalTo(view).multipliedBy(0.8)
            make.center.equalTo(view)
            make.height.equalTo(110)
        }
    }
    
}
