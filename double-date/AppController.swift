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

enum RootRouter {
    case inital(InitalRouter)
}

final class AppController: UIViewController {
    
    static let shared = AppController()
    
    //MARK: - Private Props
    private let disposeBag = DisposeBag()
    private let userService = UserService()
    private let errorTracker = ErrorTracker()
    private var actingVC: UIViewController = UIViewController()
    private var rootRouter: Navigateable = InitalRouter()
    
    //MARK: - Public Props
    var currentUser = Variable<User?>(nil)
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isStatusBarHidden = true
        actingVC.view.backgroundColor = .white
        switchToRouter(rootRouter)
        bindViewModel()
    }
    
    func bindViewModel() {
 
        currentUser.asObservable()
            .filterNil().take(1)
            .subscribe(onNext: { _ in
                print("I'm inside current user")
                //self.actingVC = self.createHomeViewController()
                //self.addChild(self.actingVC, frame: self.view.frame, animated: true)
            })
            .disposed(by: disposeBag)

        errorTracker.asDriver()
            .drive(onNext: { [unowned self] error in
                print("ERRORRRORROR: \(error)")
                self.switchToRouter(self.rootRouter)
            })
            .disposed(by: disposeBag)
        
        userService.getCurrentUser()
            .trackNetworkError(errorTracker)
            .asDriverOnErrorJustComplete()
            .drive(onNext: { [unowned self] in
                print("Feteched user: \($0)")
                self.currentUser.value = $0
            })
            .disposed(by: disposeBag)
        
        let createOnboarding$ = NotificationCenter.default.rx.notification(.createOnboarding).asDriverOnErrorJustComplete()
        let createHomeNotif$ = NotificationCenter.default.rx.notification(.createHomeVc).asDriverOnErrorJustComplete()
        let logoutNotif$ = NotificationCenter.default.rx.notification(.createHomeVc).asDriverOnErrorJustComplete()
        
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
        switch notification.name {
        case Notification.Name.createOnboarding: switchToRouter(OnboardingRouter())
        case Notification.Name.createHomeVc: break
        case Notification.Name.logout: switchToRouter(InitalRouter())
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
