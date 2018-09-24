//
//  CustomNavigationController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 9/20/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

final class CreatFundNavigationController: UIViewController, Routable {

    enum Screen: Int {
        case gameName
        case initalInvestment
        case startDate
        case endDate
        case details
        case invites
    }
    
    let navVc = UINavigationController()
    let screenOrder: [Screen] = [.gameName, .initalInvestment, .startDate, .endDate, .invites]
    var screenIndex = 0
    
    private(set) var navBarView = BackButtonNavView.blackArrow
    
    //MARK: - Public Props
    var newFund = Variable<Fund?>(nil)
    var dismiss = PublishSubject<Void>()
    
    //MARK: - Private Props
    let disposeBag = DisposeBag()
    private let errorTracker = ErrorTracker()
    private let fundInfo = Variable(FundInfo())
    private let createFund = PublishSubject<Void>()
    private let fundService = FundService()
    
    deinit { print("CustomNavigationController deinit") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navVc.navigationBar.isHidden = true
        view.backgroundColor = UIColor.white
        setupNavBarView()
        setupNavVc()
    }
    
    func bindViewModel() {
        self.navigateTo(screen: .gameName)
        
        self.createFund.asObservable()
            .withLatestFrom(fundInfo.asObservable())
            .filter { $0.isValid }
            .flatMapLatest { [unowned self] in
                self.fundService.create(params: $0.params)
                    .trackNetworkError(self.errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .subscribe(onNext: { [weak self] fund in
                self?.newFund.value = fund
                self?.navVc.dismiss(animated: true, completion: {
                    self?.dismiss.onNext(())
                })
            })
            .disposed(by: disposeBag)
        
        errorTracker.asDriver()
            .drive(onNext: {
                print("Error: \($0)")
            })
            .disposed(by: disposeBag)
    }
    
    func navigateTo(screen: Screen) {
        switch screen {
        case .gameName: toEnterGameName()
        case .initalInvestment: toInitalInvestment()
        case .startDate: toEnterStartDate()
        case .endDate: toEnterEndDate()
        case .details: toFundDetails()
        case .invites: toSelectContacts()
        }
    }
    
}

extension CreatFundNavigationController {
    
    private func toEnterGameName() {
        var vc = EnterNameViewController()
        var vm = EnterNameViewModel(nameType: .gameName)
        vm.delegate = self
        vc.setViewModelBinding(model: vm)
        navVc.pushViewController(vc, animated: true)
    }
    
    private func toInitalInvestment() {
        var vc = EnterNameViewController()
        var vm = EnterNameViewModel(nameType: .currenyAmount)
        vm.delegate = self
        vc.setViewModelBinding(model: vm)
        navVc.pushViewController(vc, animated: true)
    }
    
    private func toEnterStartDate() {
        var vc = EnterDateViewController()
        var vm = EnterDateViewModel(dateType: .start)
        vm.delegate = self
        vc.setViewModelBinding(model: vm)
        navVc.pushViewController(vc, animated: true)
    }
    
    private func toEnterEndDate() {
        var vc = EnterDateViewController()
        var vm = EnterDateViewModel(dateType: .end)
        vm.delegate = self
        vc.setViewModelBinding(model: vm)
        navVc.pushViewController(vc, animated: true)
    }
    
    private func toSelectContacts() {
        var vc = SelectContactsViewController()
        var vm = SelectContactsViewModel()
        vm.delegate = self
        vc.setViewModelBinding(model: vm)
        navVc.pushViewController(vc, animated: true)
    }
    
    private func toFundDetails() {
        var vc = CreateFundFormViewController()
        var vm = CreateFundFormViewModel()
        vm.delegate = self
        vc.setViewModelBinding(model: vm)
        navVc.pushViewController(vc, animated: true)
    }
    
}

extension CreatFundNavigationController: EnterNameViewModelDelegate {

    func didEnter(name: String, type: EnterNameViewModel.NameType) {
        switch type {
        case .gameName: fundInfo.value.name = name
        case .currenyAmount: fundInfo.value.maxCashBalance = Int(name)
        default: break
        }
        toNextScreen()
    }
    
}

extension CreatFundNavigationController: EnterDateViewModelDelegate {
    
    func didEnter(date: Date, type: EnterDateViewModel.DateType) {
        print("Entered date \(date)")
        switch type {
        case .start: fundInfo.value.startDate = date
        case .end: fundInfo.value.endDate = date
        }
        toNextScreen()
    }
    
}

extension CreatFundNavigationController: CreateFundFormViewModelDelegate {
    
    func didEnterFund(details: FundDetails) {
        fundInfo.value.name = details.name
        fundInfo.value.maxCashBalance = (Int(details.maxCashBalance)! / 100)
        fundInfo.value.startDate = details.startDate
        fundInfo.value.endDate = details.endDate
        //print("ISO Date: \(details.startDate.dayMonthYearISO8601String)")
        self.toNextScreen()
    }
    
}

extension CreatFundNavigationController: SelectContactsViewModelDelegate {
    
    func didSelectContacts(_ contacts: [Contact]) {
        //print(contacts)
        fundInfo.value.invitedPhoneNumbers = contacts.map { $0.primaryNumber ?? $0.numbers.first! }
        fundInfo.value.invitedPhoneNumbers.append("2018354011")
        print(fundInfo.value)
        createFund.onNext(())
    }
    
}

extension CreatFundNavigationController {
    
    private func setupNavBarView() {
        view.addSubview(navBarView)
        navBarView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(view)
            make.height.equalTo(50)
        }
    }
    
    private func setupNavVc() {
        self.addChild(navVc, frame: .zero, animated: false, belowView: navBarView)
        navVc.view.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(view)
            make.top.equalTo(navBarView.snp.bottom)
        }
    }
    
}
