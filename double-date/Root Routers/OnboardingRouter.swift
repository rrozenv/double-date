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
    
    init() {
        self.firstName = nil
        self.lastName = nil
        self.city = nil
        self.phoneNumber = nil
    }
    
    init(firstName: String?, lastName: String, city: String?, phoneNumber: String?) {
        self.firstName = firstName
        self.lastName = lastName
        self.city = city
        self.phoneNumber = phoneNumber
    }
}

final class OnboardingRouter: Routable {
    
    enum Screen {
        case firstName
        case lastName
    }
    
    //MARK: - Private Props
    private let disposeBag = DisposeBag()
    private let onboardingInfo = OnboardingInfo()
    
    //MARK: - Routable Props
    let navVc = UINavigationController()
    let screenOrder: [Screen] = [.firstName, .lastName]
    var screenIndex = 0
    
    init() {
        self.navigateTo(screen: .firstName)
        navVc.isNavigationBarHidden = true
    }
    
    func navigateTo(screen: Screen) {
        switch screen {
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
