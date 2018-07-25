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
    var onboardType: PhoneEntryViewModel.DisplayType = .signup
    var name: String?
    var phoneNumber: String?
    
    var isValid: Bool {
        switch onboardType {
        case .signup:
            return name != nil && phoneNumber != nil
        case .login:
            return phoneNumber != nil
        }
    }
   
    var json: [String: Any] {
        guard isValid else { return [:] }
        switch onboardType {
        case .signup:
            return [
                "name": name!,
                "phoneNumber": phoneNumber!.digits
            ]
        case .login:
            return [
                "phoneNumber": phoneNumber!.digits
            ]
        }
    }
}

final class OnboardingRouter: Routable {
    
    enum Screen {
        case inital
        case name
        case phoneNumber(displayType: PhoneEntryViewModel.DisplayType)
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
    var screenOrder: [Screen] = [.inital, .name, .phoneNumber(displayType: .signup), .verificationCode(countryCode: "", phoneNumber: "")]
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
            .map { [unowned self] info -> Observable<User> in
                switch info.onboardType {
                case .signup: return self.createUserObservable(info: info)
                case .login: return self.loginUserObservable()
                }
            }
            .switchLatest()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in
                guard let sSelf = self else { return }
                AppController.shared.setCurrentUser(user)
                switch sSelf.onboardingInfo.value.onboardType {
                case .signup: self?.navigateTo(screen: .enableNotifications)
                case .login: NotificationCenter.default.post(name: .createHomeVc, object: nil)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func createUserObservable(info: OnboardingInfo) -> Observable<User> {
        return self.userService.createUser(params: info.json)
            .trackNetworkError(self.errorTracker)
            .trackActivity(self.activityTracker)
    }
    
    private func loginUserObservable() -> Observable<User> {
        return self.userService.loginUser(phoneNumber: onboardingInfo.value.phoneNumber!)
            .trackNetworkError(self.errorTracker)
            .trackActivity(self.activityTracker)
    }
    
    func navigateTo(screen: Screen) {
        DispatchQueue.main.async {
            switch screen {
            case .inital: self.toInitalScene()
            case .phoneNumber(let displayType): self.toPhoneNumber(displayType: displayType)
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
        var vc = EnterNameViewController()
        var vm = EnterNameViewModel(nameType: .first)
        vm.delegate = self
        vc.setViewModelBinding(model: vm)
        navVc.pushViewController(vc, animated: true)
    }
    
    private func toPhoneNumber(displayType: PhoneEntryViewModel.DisplayType) {
        var vc = PhoneEntryViewController()
        var vm = PhoneEntryViewModel(displayType: displayType)
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
        self.onboardingInfo.value.onboardType = .signup
        self.screenOrder = [.inital, .name, .phoneNumber(displayType: .signup), .verificationCode(countryCode: "", phoneNumber: "")]
        toNextScreen()
    }
    
    func didTapLogInButton() {
        self.onboardingInfo.value.onboardType = .login
        self.screenOrder = [.inital, .phoneNumber(displayType: .login), .verificationCode(countryCode: "", phoneNumber: "")]
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
