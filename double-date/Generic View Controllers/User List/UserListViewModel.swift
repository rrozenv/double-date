//
//  UserListViewModel.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/15/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct UsersViewModel {
    
    let disposeBag = DisposeBag()
    
    //MARK: - Properties
    private let _user = Variable<User?>(nil)
    private let errorTracker: ErrorTracker
    private let userService: UserService
    
    //MARK: - Init
    init(userService: UserService = UserService(),
         errorTracker: ErrorTracker = ErrorTracker()) {
        self.userService = userService
        self.errorTracker = errorTracker
        getCurrentUser().drive(_user).disposed(by: disposeBag)
    }
    
    //MARK: - Outputs
    var user: Driver<User> {
        return _user.asDriver().filterNil()
    }
    
    var error: Driver<NetworkError> {
        return errorTracker.asDriver()
    }
    
    //MARK: - Inputs
    func bindContinueButton(_ observable: Observable<Void>) {
        observable
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .flatMapLatest { _ in self.getCurrentUser() }
            .subscribe(onNext: { self._user.value = $0 })
            .disposed(by: disposeBag)
    }
    
    private func getCurrentUser() -> Driver<User> {
        return userService.getCurrentUser()
            .trackNetworkError(errorTracker)
            .asDriverOnErrorJustComplete()
    }
    
}
