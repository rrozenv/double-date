//
//  StockDetailViewModel.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/27/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

enum PositionType: String, Codable {
    case buy, sell
}

protocol BackButtonNavigatable: class {
    func didTapBackButton()
}

protocol StockDetailViewModelDelegate: BackButtonNavigatable {
    func didSelectPositionType(_ type: PositionType)
}

struct StockDetailViewModel {
    
    //MARK: - Properties
    let disposeBag = DisposeBag()
    private let stockService = StockService()
    private let _stockSummary: Variable<StockSummary?>
    private let _stock: Variable<Stock?>
    private let _display = PublishSubject<Void>()
    private let _shouldDismiss = PublishSubject<Void>()
    let activityIndicator = PublishSubject<Bool>()
    let outerErrorTracker = PublishSubject<NetworkError>()
    let innerErrorTracker = ErrorTracker()
    weak var delegate: StockDetailViewModelDelegate?
    
    init(stock: Stock) {
        self._stock = Variable(stock)
        self._stockSummary = Variable(nil)
    }
    
    init(stockSummary: StockSummary) {
       self._stock = Variable(nil)
       self._stockSummary = Variable(stockSummary)
    }
    
    //MARK: - Outputs
    var stock: Driver<Stock> {
        return _stock.asDriver().filterNil()
    }
    
    var shouldDismiss: Observable<Void> {
        return _shouldDismiss.asObservable()
    }
    
    var isLoading: Driver<Bool> {
        return activityIndicator.asDriver(onErrorJustReturn: false)
    }
    
    var error: Driver<NetworkError> {
        return Driver.merge(outerErrorTracker.asDriverOnErrorJustComplete(), innerErrorTracker.asDriver())
    }
    
    //MARK: - Inputs
    func bindFetchStockDetails(_ observable: Observable<Void>) {
        observable
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInitiated))
            .map { self._stockSummary.value }
            .filterNil()
            .flatMapLatest {
                self.stockService.getDetailsFor(stockSummary: $0)
                    .trackNetworkError(self.innerErrorTracker)
            }
            .bind(to: _stock)
            .disposed(by: disposeBag)
    }
    
    func bindSelectedPositionType(_ observable: Observable<PositionType>) {
        observable
            .subscribe(onNext: { type in
                self.delegate?.didSelectPositionType(type)
            })
            .disposed(by: disposeBag)
    }
    
    func bindBackButton(_ observable: Observable<Void>) {
        observable
            .subscribe(onNext: {
                self.delegate?.didTapBackButton()
            })
            .disposed(by: disposeBag)
    }
    
}

/// Testing

//enum MultipleSectionModel {
//    case quoteSection(title: String, items: [SectionItem])
//    case newsSection(title: String, items: [SectionItem])
//}
//
//enum SectionItem {
//    case quoteSectionItem(Stock)
//    case newsSectionItem(Stock)
//}
//
//extension MultipleSectionModel: SectionModelType {
//    typealias Item = SectionItem
//
//    var items: [SectionItem] {
//        switch  self {
//        case .quoteSection(title: _, items: let items):
//            return items.map {$0}
//        case .newsSection(title: _, items: let items):
//            return items.map {$0}
//        }
//    }
//
//    init(original: MultipleSectionModel, items: [Item]) {
//        switch original {
//        case .quoteSection(title: title, items: let items):
//             self = .quoteSection(title: title, items: items)
//        case .newsSection(title: title, items: let items):
//             self = .newsSection(title: title, items: items)
//        }
//    }
//}
//
//extension MultipleSectionModel {
//    var title: String {
//        switch self {
//        case .quoteSection(title: let title, items: _):
//            return title
//        case .newsSection(title: let title, items: _):
//            return title
//        }
//    }
//}

