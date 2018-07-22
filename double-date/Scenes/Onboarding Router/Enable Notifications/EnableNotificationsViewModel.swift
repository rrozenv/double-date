//
//  EnableNotificationsViewModel.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/20/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UserNotifications

protocol EnableNotificationsViewModelDelegate: class {
    func didSelectNotificationOption()
}

struct EnableNotificationsViewModel {
    
    let disposeBag = DisposeBag()
    private let errorTracker = ErrorTracker()
    weak var delegate: EnableNotificationsViewModelDelegate?
    
    //MARK: - Outputs
    var error: Driver<NetworkError> {
        return errorTracker.asDriver()
    }
    
    func bindEnableButton(_ observable: Observable<Void>) {
        observable
            .flatMap { self.registerForPushNotifications() }
            .subscribe(onNext: { _ in
                self.delegate?.didSelectNotificationOption()
            })
            .disposed(by: disposeBag)
    }
    
    func bindSkipButton(_ observable: Observable<Void>) {
        observable
            .subscribe(onNext: { _ in
                self.delegate?.didSelectNotificationOption()
            })
            .disposed(by: disposeBag)
    }
    
    private func registerForPushNotifications() -> Observable<Void> {
        return Observable.create { (observer) -> Disposable in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, error) in
                print("Permission granted: \(granted)")
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
                observer.onNext(())
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
}
