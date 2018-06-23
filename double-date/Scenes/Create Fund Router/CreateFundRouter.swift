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
}

final class CreateFundRouter: Routable {
    
    enum Screen {
        case details
        case invites
    }
    
    //MARK: - Private Props
    let disposeBag = DisposeBag()
    private let fundInfo = FundInfo()
    
    //MARK: - Routable Props
    let navVc = UINavigationController()
    let screenOrder: [Screen] = [.details, .invites]
    var screenIndex = 0
    
    //MARK: - Public Props
    var newFund = Variable<Fund?>(nil)
    var dismiss = PublishSubject<Void>()
    
    init() {
        self.navigateTo(screen: .details)
        navVc.isNavigationBarHidden = true
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
        fundInfo.name = details.name
        fundInfo.maxPlayers = details.maxPlayers
        self.toNextScreen()
    }
    
}

extension CreateFundRouter: SelectContactsViewModelDelegate {
    
    func didSelectContacts(_ contacts: [Contact]) {
        print(contacts)
        fundInfo.invitedPhoneNumbers = contacts.map { $0.primaryNumber ?? $0.numbers.first! }
        let fund = Fund(_id: UUID().uuidString, name: fundInfo.name!, maxPlayers: fundInfo.maxPlayers!)
        newFund.value = fund
        navVc.dismiss(animated: true, completion: { [unowned self] in
            self.dismiss.onNext(())
        })
    }
    
    func didTapBackButton() {
        self.toPreviousScreen()
    }
    
}
