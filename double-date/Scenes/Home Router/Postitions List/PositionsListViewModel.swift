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
    private let fundService = FundService()
    let _fund: Variable<Fund>
    private let _positions: Variable<[Position]>
    private let errorTracker = ErrorTracker()
    private let _didClosePosition = PublishSubject<Position>()
    
    init(fund: Fund) {
        self._fund = Variable(fund)
        self._positions = Variable(fund.currentUserPortfolio.positions)
    }
    
    //MARK: - Outputs
    var sections: Observable<[PositionListMultipleSectionModel]> {
        return _fund.asObservable()
            .map { $0.currentUserPortfolio.positions }
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInitiated))
            .map { self.createSectionsFor(positions: $0) }
    }
    
    var displayDidClosePositionAlert: Driver<Position> {
        return _didClosePosition.asDriverOnErrorJustComplete()
    }
    
    var error: Driver<NetworkError> {
        return errorTracker.asDriver()
    }
    
    func bindFetchPositions(_ observable: Observable<Void>) {
        observable
            .flatMapLatest { _ in
                self.positionService.getPositionsFor(fundId: self._fund.value._id)
                    .trackNetworkError(self.errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .bind(to: _positions)
            .disposed(by: disposeBag)
    }
    
    func bindClosePosition(_ observable: Observable<Position>) {
        observable
            .flatMapLatest {
                self.positionService.closePosition(posId: $0._id,
                                                   portfolioId: self._fund.value.currentUserPortfolio._id)
                    .trackNetworkError(self.errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .subscribe(onNext: { updatedPos in
                guard let index = self._positions.value.index(where: { $0._id == updatedPos._id }) else { return }
                self._positions.value[index] = updatedPos
                self._didClosePosition.onNext(updatedPos)
            })
            .disposed(by: disposeBag)
    }
    
    func bindFetchUpdatedFund(_ observable: Observable<Void>) {
        observable
            .flatMapLatest { _ in
                self.fundService.getFund(id: self._fund.value._id)
                    .trackNetworkError(self.errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .bind(to: _fund)
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

extension PositionsListViewModel {
    
    private func createSectionsFor(positions: [Position]) -> [PositionListMultipleSectionModel] {
        var sections = [PositionListMultipleSectionModel]()
        let openPositions = positions.filter { $0.status == .open }
        let closedPositions = positions.filter { $0.status == .closed }
        
        if openPositions.isNotEmpty {
            sections.append(
                PositionListMultipleSectionModel.openPositons(title: "OPEN",
                                                              items: openPositions)
            )
        }
        
        if closedPositions.isNotEmpty {
            sections.append(
                PositionListMultipleSectionModel.closedPositons(title: "CLOSED",
                                                              items: closedPositions)
            )
        }
        
        return sections
    }
    
}
