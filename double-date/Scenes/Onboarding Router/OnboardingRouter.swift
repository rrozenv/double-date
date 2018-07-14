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
        case verificationCode(countryCode: String, phoneNumber: String)
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
        DispatchQueue.main.async {
            switch screen {
            case .phoneNumber: self.toPhoneNumber()
            case .verificationCode(countryCode: let code, phoneNumber: let phone):
                self.toVerificationCode(countryCode: code, phoneNumber: phone)
            case .firstName: self.toFirstName()
            case .lastName: self.toLastName()
            }
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
    
    private func toVerificationCode(countryCode: String, phoneNumber: String) {
        var vc = PhoneVerificationViewController()
        var vm = PhoneVerificationViewModel(countryCode: countryCode, phoneNumber: phoneNumber)
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
    
    func didEnter(countryCode: String, phoneNumber: String) {
        navigateTo(screen: .verificationCode(countryCode: countryCode, phoneNumber: phoneNumber))
    }
    
}

extension OnboardingRouter: PhoneVerificationViewModelDelegate {
    
    func didValidateVerificationCode() {
        print("CODE VALIDATED!")
        //NotificationCenter.default.post(name: .createHomeVc, object: nil)
    }
    
}
