//
//  CreateFundRouter.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/22/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

final class FundInfo {
    var name: String?
    var maxCashBalance: Int?
    var startDate: Date?
    var endDate: Date?
    var invitedPhoneNumbers: [String] = []
    
    var isValid: Bool {
        guard let name = name,
              let maxCashBalance = maxCashBalance,
              let startDate = startDate,
              let endDate = endDate else { return false }
        return name.count > 3 &&
               invitedPhoneNumbers.count > 0 &&
               maxCashBalance > 0
                //&& startDate < endDate
    }
    
    var params: [String: Any] {
        return [
            "name": name ?? "",
            "maxCashBalance": maxCashBalance ?? 0,
            "invitedPhoneNumbers": invitedPhoneNumbers,
            "startDate": startDate?.dayMonthYearOnly?.iso8601String ?? "",
            "endDate": endDate?.dayMonthYearOnly?.iso8601String ?? ""
        ]
    }
}

final class CreateFundRouter: Routable {
    
    enum Screen: Int {
        case startDate
        case details
        case invites
    }
    
    //MARK: - Private Props
    let disposeBag = DisposeBag()
    private let errorTracker = ErrorTracker()
    private let fundInfo: Variable<FundInfo>
    private let createFund = PublishSubject<Void>()
    private let fundService = FundService()
    
    //MARK: - Routable Props
    let navVc = UINavigationController()
    let screenOrder: [Screen] = [.details, .invites]
    var screenIndex = 0
    
    //MARK: - Public Props
    var newFund = Variable<Fund?>(nil)
    var dismiss = PublishSubject<Void>()
    
    init() {
        self.fundInfo = Variable(FundInfo())
        self.navigateTo(screen: .details)
        self.navVc.isNavigationBarHidden = true
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
    
    deinit { print("CreateFundRouter deinit") }

    func navigateTo(screen: Screen) {
        switch screen {
        case .startDate: toEnterStartDate()
        case .details: toFundDetails()
        case .invites: toSelectContacts()
        }
    }
    
    func didTapBackButton() {
        guard let currentScreen = Screen(rawValue: screenIndex) else { return }
        switch currentScreen {
        case .startDate: break
        case .details:
            self.toPreviousScreen(completion: { [weak self] in
                self?.dismiss.onNext(())
            })
        case .invites:
            self.toPreviousScreen()
        }
    }
    
}

extension CreateFundRouter {
    
    private func toEnterStartDate() {
        var vc = EnterDateViewController()
        var vm = EnterDateViewModel(dateType: .start)
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
    
    private func toSelectContacts() {
        var vc = SelectContactsViewController()
        var vm = SelectContactsViewModel()
        vm.delegate = self
        vc.setViewModelBinding(model: vm)
        navVc.pushViewController(vc, animated: true)
    }

}

extension CreateFundRouter: EnterDateViewModelDelegate {
    
    func didEnter(date: Date, type: EnterDateViewModel.DateType) {
        print(date)
    }
    
}

extension CreateFundRouter: CreateFundFormViewModelDelegate {
    
    func didEnterFund(details: FundDetails) {
        fundInfo.value.name = details.name
        fundInfo.value.maxCashBalance = (Int(details.maxCashBalance)! / 100)
        fundInfo.value.startDate = details.startDate
        fundInfo.value.endDate = details.endDate
        //print("ISO Date: \(details.startDate.dayMonthYearISO8601String)")
        self.toNextScreen()
    }
    
}

extension CreateFundRouter: SelectContactsViewModelDelegate {
    
    func didSelectContacts(_ contacts: [Contact]) {
        //print(contacts)
        fundInfo.value.invitedPhoneNumbers = contacts.map { $0.primaryNumber ?? $0.numbers.first! }
        fundInfo.value.invitedPhoneNumbers.append("2018354011")
        print(fundInfo.value)
        createFund.onNext(())
    }
    
}
