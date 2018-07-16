//
//  AppController.swift
//  HousePartyApp
//
//  Created by Robert Rozenvasser on 5/6/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxOptional

//enum RootRouter {
//    case inital(InitalRouter)
//}

final class AppController: UIViewController {
    
    static let shared = AppController()
    
    //MARK: - Private Props
    private let disposeBag = DisposeBag()
    private let userService = UserService()
    private let errorTracker = ErrorTracker()
    private var actingVC: UIViewController = UIViewController()
    private var rootRouter: Navigateable = OnboardingRouter()
    
    //MARK: - Public Props
    private var currentUser = Variable<User?>(nil)
    
    var user: User {
        guard let user = currentUser.value else { fatalError("current user not set...") }
        return user
    }
    
    var user$: Observable<User?> {
        return currentUser.asObservable()
    }
    
    private init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        actingVC.view.backgroundColor = .white
        addNotificationObservers()
        loadInitialViewController()
      
        currentUser.asObservable()
            .filterNil()
            .subscribe(onNext: { _ in
                print("Current user was set!")
            })
            .disposed(by: disposeBag)
    }
    
    func setCurrentUser(_ user: User) {
        currentUser.value = user
    }
    
    private func loadInitialViewController() {
        if let _ = MyKeychain.shared.getStringFor(Secrets.tokenKeyString) {
            switchToRouter(HomeRouter())
        } else {
            switchToRouter(rootRouter)
        }
    }
    
    private func addNotificationObservers() {
        let createOnboarding$ = NotificationCenter.default.rx.notification(.createOnboarding).asDriverOnErrorJustComplete()
        let createHomeNotif$ = NotificationCenter.default.rx.notification(.createHomeVc).asDriverOnErrorJustComplete()
        let logoutNotif$ = NotificationCenter.default.rx.notification(.logout).asDriverOnErrorJustComplete()
        
        Driver.merge(createOnboarding$, createHomeNotif$, logoutNotif$)
            .drive(onNext: { [weak self] in
                self?.switchViewController(with: $0)
            })
            .disposed(by: disposeBag)
    }

}

// MARK: - Displaying VC's
extension AppController {
    
    @objc func switchViewController(with notification: Notification) {
        print("recieved notif")
        switch notification.name {
        case Notification.Name.createOnboarding: switchToRouter(OnboardingRouter())
        case Notification.Name.createHomeVc: switchToRouter(HomeRouter())
        case Notification.Name.logout: switchToRouter(OnboardingRouter())
        default:
            fatalError("\(#function) - Unable to match notficiation name.")
        }
    }

    private func switchToRouter(_ router: Navigateable) {
        self.removeChild(actingVC, completion: nil)
        self.rootRouter = router
        self.actingVC = router.navVc
        self.addChild(self.actingVC, frame: self.view.frame, animated: true)
    }
    
}
