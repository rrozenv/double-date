//
//  OnboardingRouter.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/16/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

final class OnboardingInfo {
    var firstName: String?
    var lastName: String?
    var city: String?
    var phoneNumber: String?
}

final class OnboardingRouter: Routable {
    
    enum Screen {
        case firstName
        case lastName
        case phoneNumber
    }
    
    //MARK: - Private Props
    private let disposeBag = DisposeBag()
    private let onboardingInfo = OnboardingInfo()
    
    //MARK: - Routable Props
    let navVc = UINavigationController()
    let screenOrder: [Screen] = [.phoneNumber]
    var screenIndex = 0
    
    init() {
        self.navigateTo(screen: .phoneNumber)
        navVc.isNavigationBarHidden = true
    }
    
    func navigateTo(screen: Screen) {
        switch screen {
        case .phoneNumber: toPhoneNumber()
        case .firstName: toFirstName()
        case .lastName: toLastName()
        }
    }
    
}

extension OnboardingRouter {
    
    private func toFirstName() {
        var vc = EnterNameViewController<EnterNameViewModel>()
        var vm = EnterNameViewModel(nameType: .first)
        vm.delegate = self
        vc.setViewModelBinding(model: vm)
        navVc.pushViewController(vc, animated: false)
    }
    
    private func toLastName() {
        var vc = EnterNameViewController<EnterNameViewModel>()
        var vm = EnterNameViewModel(nameType: .last)
        vm.delegate = self
        vc.setViewModelBinding(model: vm)
        navVc.pushViewController(vc, animated: true)
    }
    
    private func toPhoneNumber() {
        var vc = PhoneEntryViewController()
        var vm = PhoneEntryViewModel()
        vm.delegate = self
        vc.setViewModelBinding(model: vm)
        navVc.pushViewController(vc, animated: true)
    }
    
}

extension OnboardingRouter: EnterNameViewModelDelegate {
    
    func didTapBackButton(nameType: EnterNameViewModel.NameType) {
        self.toPreviousScreen()
    }
    
    func didEnter(name: String, type: EnterNameViewModel.NameType) {
        switch type {
        case .first:
            onboardingInfo.firstName = name
        case .last: onboardingInfo.lastName = name
        }
        toNextScreen()
    }
    
}

extension OnboardingRouter: PhoneEntryViewModelDelegate {

    func didEnter(phoneNumber: String) {
        print(phoneNumber)
        NotificationCenter.default.post(name: .createHomeVc, object: nil)
    }
    
}
