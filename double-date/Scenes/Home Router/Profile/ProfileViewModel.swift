//
//  ProfileViewModel.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/24/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ProfileViewModelDelegate: class {
    func didTapLogoutButton()
}

struct ProfileViewModel {
    
    let disposeBag = DisposeBag()
    private let positionService = PositionService()
    private let _positions = Variable<[Position]>([])
    private let errorTracker = ErrorTracker()
    weak var delegate: ProfileViewModelDelegate?

    //MARK: - Outputs
    var positions: Driver<[Position]> {
        return _positions.asDriver()
    }
    
    var error: Driver<NetworkError> {
        return errorTracker.asDriver()
    }
    
    func bindLogoutButton(_ observable: Observable<Void>) {
        observable
            .subscribe(onNext: {
                let _ = MyKeychain.shared.removeAllValues()
                self.delegate?.didTapLogoutButton()
            })
            .disposed(by: disposeBag)
    }
    
    func bindFetchPositions(_ observable: Observable<Void>) {
        observable
            .flatMapLatest {
                self.positionService.getPositions()
                    .trackNetworkError(self.errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .bind(to: _positions)
            .disposed(by: disposeBag)
    }
    
    func bindNewPosition(_ observable: Observable<Position>) {
        observable
            .subscribe(onNext: {
                self._positions.value.insert($0, at: 0)
            })
            .disposed(by: disposeBag)
    }
    
}
