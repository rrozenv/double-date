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
    var maxPlayers: Int?
    var invitedPhoneNumbers: [String] = []
    
    var isValid: Bool {
        guard let name = name, let maxPlayers = maxPlayers else { return false }
        return name.count > 3 && maxPlayers > 0 && invitedPhoneNumbers.count > 0
    }
    
    var params: [String: Any] {
        return [
            "name": name ?? "",
            "maxPlayers": maxPlayers ?? 0
        ]
    }
}

final class CreateFundRouter: Routable {
    
    enum Screen {
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
                self.fundService.create(params:  $0.params)
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
        case .details: toFundDetails()
        case .invites: toSelectContacts()
        }
    }
    
}

extension CreateFundRouter {
    
    private func toFundDetails() {
        var vc = FundDetailsViewController()
        var vm = FundDetailsViewModel()
        vm.delegate = self
        vc.setViewModelBinding(model: vm)
        navVc.pushViewController(vc, animated: false)
    }
    
    private func toSelectContacts() {
        var vc = SelectContactsViewController()
        var vm = SelectContactsViewModel()
        vm.delegate = self
        vc.setViewModelBinding(model: vm)
        navVc.pushViewController(vc, animated: false)
    }

}

extension CreateFundRouter: FundDetailsViewModelDelegate {
    
    func didEnterFund(details: FundDetails) {
        fundInfo.value.name = details.name
        fundInfo.value.maxPlayers = details.maxPlayers
        self.toNextScreen()
    }
    
}

extension CreateFundRouter: SelectContactsViewModelDelegate {
    
    func didSelectContacts(_ contacts: [Contact]) {
        print(contacts)
        fundInfo.value.invitedPhoneNumbers = contacts.map { $0.primaryNumber ?? $0.numbers.first! }
        createFund.onNext(())
    }
    
    func didTapBackButton() {
        self.toPreviousScreen()
    }
    
}
