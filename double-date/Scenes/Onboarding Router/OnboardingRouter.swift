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
    var name: String?
    var phoneNumber: String?
    
    var isValid: Bool {
        return name != nil && phoneNumber != nil
    }
   
    var json: [String: Any] {
        guard isValid else { return [:] }
        return [
            "name": name!,
            "phoneNumber": phoneNumber!.digits
        ]
    }
}

final class OnboardingRouter: Routable {
    
    enum Screen {
        case inital
        case name
        case phoneNumber
        case verificationCode(countryCode: String, phoneNumber: String)
        case enableNotifications
    }
    
    //MARK: - Private Props
    private let disposeBag = DisposeBag()
    private let onboardingInfo: Variable<OnboardingInfo>
    private let userService = UserService()
    private let activityTracker = ActivityIndicator()
    private let errorTracker = ErrorTracker()
    private let createUser = PublishSubject<Void>()
    
    //MARK: - Routable Props
    let navVc = UINavigationController()
    let screenOrder: [Screen] = [.inital, .name, .phoneNumber, .verificationCode(countryCode: "", phoneNumber: "")]
    var screenIndex = 0
    
    init() {
        self.onboardingInfo = Variable(OnboardingInfo())
        self.navVc.isNavigationBarHidden = true
        self.setupCreateUser()
        self.navigateTo(screen: screenOrder[screenIndex])
        self.errorTracker.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.navVc.displayNetworkError($0)
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        print("OnboardingRouter deinit")
    }
    
    private func setupCreateUser() {
        self.createUser.asObservable()
            .withLatestFrom(onboardingInfo.asObservable())
            .filter { $0.isValid }
            .flatMapLatest { [unowned self] in
                self.userService.createUser(params: $0.json)
                    .trackNetworkError(self.errorTracker)
                    .trackActivity(self.activityTracker)
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                AppController.shared.setCurrentUser($0)
                self?.navigateTo(screen: .enableNotifications)
            })
            .disposed(by: disposeBag)
    }
    
    func navigateTo(screen: Screen) {
        DispatchQueue.main.async {
            switch screen {
            case .inital: self.toInitalScene()
            case .phoneNumber: self.toPhoneNumber()
            case .verificationCode(countryCode: let code, phoneNumber: let phone):
                self.toVerificationCode(countryCode: code, phoneNumber: phone)
            case .name: self.toFirstName()
            case .enableNotifications: self.toEnableNotifications()
            }
        }
    }
    
    func didTapBackButton() {
        DispatchQueue.main.async {
            self.toPreviousScreen(completion: nil)
        }
    }
    
}

extension OnboardingRouter {
    
    private func toInitalScene() {
        var vc = InitialViewController()
        var vm = InitialViewModel()
        vm.delegate = self
        vc.setViewModelBinding(model: vm)
        navVc.pushViewController(vc, animated: false)
    }
    
    private func toFirstName() {
        var vc = EnterNameViewController<EnterNameViewModel>()
        var vm = EnterNameViewModel(nameType: .first)
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
    
    private func toEnableNotifications() {
        var vc = EnableNotificationsViewController()
        var vm = EnableNotificationsViewModel()
        vm.delegate = self
        vc.setViewModelBinding(model: vm)
        navVc.pushViewController(vc, animated: true)
    }
    
}

extension OnboardingRouter: InitalViewModelDelegate {
    
    func didTapContinueButton() {
        toNextScreen()
    }
    
}

extension OnboardingRouter: EnterNameViewModelDelegate {
    
    func didEnter(name: String, type: EnterNameViewModel.NameType) {
        onboardingInfo.value.name = name
        toNextScreen()
    }
    
}

extension OnboardingRouter: PhoneEntryViewModelDelegate {
    
    func didEnter(countryCode: String, phoneNumber: String) {
        onboardingInfo.value.phoneNumber = phoneNumber
        //createUser.onNext(()) //REMOVE LATER
        screenIndex += 1
        navigateTo(screen: .verificationCode(countryCode: countryCode, phoneNumber: phoneNumber))
    }
    
}

extension OnboardingRouter: PhoneVerificationViewModelDelegate {

    func didValidateVerificationCode() {
        screenIndex += 1
        createUser.onNext(())
    }
    
}

extension OnboardingRouter: EnableNotificationsViewModelDelegate {
    
    func didSelectNotificationOption() {
        NotificationCenter.default.post(name: .createHomeVc, object: nil)
    }

}
