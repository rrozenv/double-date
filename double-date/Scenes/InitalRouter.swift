//
//  InitalRouter.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/13/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

final class InitalRouter: Routable {
    
    enum Screen {
        case inital
        case signup
        case userList
    }
    
    //MARK: - Private Props
    private let disposeBag = DisposeBag()
    private var signupInfo = SignupInfo()
    private var userService: UserService
    
    //MARK: - Routable Props
    let navVc = UINavigationController()
    let screenOrder: [Screen] = [.inital, .signup]
    var screenIndex = 0
    
    init(userService: UserService = UserService()) {
        self.userService = userService
        self.navigateTo(screen: .inital)
    }
    
    func navigateTo(screen: Screen) {
        switch screen {
        case .inital: toInitalScene()
        case .signup: toSignup()
        case .userList: toUserList()
        }
    }
    
}

extension InitalRouter {
    
    private func toInitalScene() {
        var vc = InitialViewController()
        var vm = InitialViewModel()
        vm.delegate = self
        vc.setViewModelBinding(model: vm)
        navVc.pushViewController(vc, animated: false)
    }
    
    private func toSignup() {
        let vc = SignupViewController()
        vc.delegate = self
        navVc.pushViewController(vc, animated: true)
    }
    
    private func toUserList() {
        var vc = UsersViewController()
        var vm = UsersViewModel()
        vc.setViewModelBinding(model: vm)
        navVc.pushViewController(vc, animated: true)
    }
    
}

extension InitalRouter: InitalViewModelDelegate {
    
    func didTapContinueButton() {
        navigateTo(screen: .signup)
    }
    
}

extension InitalRouter: SignupViewControllerDelegate {
    
    func didCreateUser() {
        NotificationCenter.default.post(name: .createHomeVc, object: nil)
    }
    
}






final class SignupInfo {
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

