//
//  PositionsListViewModel.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/4/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct PositionsListViewModel {
    
    let disposeBag = DisposeBag()
    private let positionService = PositionService()
    private let _positions: Variable<[Position]>
    private let errorTracker = ErrorTracker()
    
    init(positions: [Position]) {
        self._positions = Variable(positions)
    }
    
    //MARK: - Outputs
    var positions: Driver<[Position]> {
        return _positions.asDriver()
    }
    
    var error: Driver<NetworkError> {
        return errorTracker.asDriver()
    }
    
//    func bindFetchPositions(_ observable: Observable<Void>) {
//        observable
//            .flatMapLatest {
//                self.positionService.getPositions()
//                    .trackNetworkError(self.errorTracker)
//                    .asDriverOnErrorJustComplete()
//            }
//            .bind(to: _positions)
//            .disposed(by: disposeBag)
//    }
    
//    func bindNewPosition(_ observable: Observable<Position>) {
//        observable
//            .subscribe(onNext: {
//                self._positions.value.insert($0, at: 0)
//            })
//            .disposed(by: disposeBag)
//    }
//
}
