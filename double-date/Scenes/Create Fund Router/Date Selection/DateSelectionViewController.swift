//
//  DateSelectionViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/22/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SnapKit

class DateSelectionViewController: UIViewController, BindableType, CustomNavBarViewable {
    
    private var nextButton: UIButton!
    var navView: BackButtonNavView = BackButtonNavView.blackArrow
    var navBackgroundView: UIView = UIView()
    private var datePicker = UIDatePicker()
    let disposeBag = DisposeBag()
    var viewModel: DateSelectionViewModel!
    var willDismiss = PublishSubject<Void>()
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .white
        setupNavBar()
//        navView.containerView.backgroundColor = Palette.lightGrey.color
//        navBackgroundView.backgroundColor = Palette.lightGrey.color
        setupDatePicker()
        setupNextButton()
    }
    
    deinit { print("DateSelectionViewController deinit") }
    
    func bindViewModel() {
        let backTapped$ = navView.backButton.rx.tap.asObservable()
        let nextTapped$ = nextButton.rx.tap.asObservable()
        Observable.merge(backTapped$, nextTapped$)
            .subscribe(onNext: { [unowned self] in
                self.willDismiss.onNext(())
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        let selectedDate$ = datePicker.rx.date.asObservable()
        viewModel.bindDateEntry(selectedDate$)
    }
    
    private func setupDatePicker() {
        view.addSubview(datePicker)
        datePicker.snp.makeConstraints { (make) in
            make.center.equalTo(view)
        }
    }
    
    private func setupNextButton() {
        nextButton = UIButton()
        nextButton.style(title: "Done")
        
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints {
            $0.height.equalTo(60)
            $0.left.right.bottom.equalTo(view)
        }
    }
    
}
