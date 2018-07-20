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

struct ChartData {
    let range: ChartRange
    var points: [ChartPoint]
}

extension ChartData {
    var pointsAsDouble: [Double] {
        return points.flatMap { $0.close }
    }
}

enum ChartRange: Int, CustomStringConvertible {
    case day, month, threeMonths, sixMonths, year
    
    var description: String {
        switch self {
        case .day: return "1d"
        case .month: return "1m"
        case .threeMonths: return "3m"
        case .sixMonths: return "6m"
        case .year: return "1y"
        }
    }
}

struct StockDetailViewModel {
    
    //MARK: - Properties
    let disposeBag = DisposeBag()
    private let stockService = StockService()
    private let _stockSummary: Variable<StockSummary?>
    private let _storedChartData = Variable<[ChartData]>([])
    private let _currentChartData = Variable<ChartData?>(nil)
    private let _stock: Variable<Stock>
    private let _display = PublishSubject<Void>()
    private let _shouldDismiss = PublishSubject<Void>()
    let activityIndicator = PublishSubject<Bool>()
    let outerErrorTracker = PublishSubject<NetworkError>()
    let innerErrorTracker = ErrorTracker()
    weak var delegate: StockDetailViewModelDelegate?
    
    init(stock: Stock) {
        self._stock = Variable(stock)
        self._stockSummary = Variable(nil)
        self._storedChartData.value = [
            ChartData(range: .day, points: stock.chart),
            ChartData(range: .month, points: []),
            ChartData(range: .threeMonths, points: []),
            ChartData(range: .sixMonths, points: []),
            ChartData(range: .year, points: [])
        ]
    }
    
    //MARK: - Outputs
    var chartSeries: Driver<ChartData> {
        return _currentChartData.asDriver().filterNil()
    }
    
    var sections: Observable<[StockDetailMultipleSectionModel]> {
        return _stock.asObservable()
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInitiated))
            .map {
                [
                    StockDetailMultipleSectionModel.quoteSection(title: "Quote",
                                                      items: [.quoteSectionItem($0.quote)]),
                    StockDetailMultipleSectionModel.newsSection(title: "News",
                                                     items: $0.news.map { StockDetailSectionItem.newsSectionItem($0) })
                ]
            }
    }
    
    var stock: Driver<Stock> {
        return _stock.asDriver()
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
    func bindSelectedRange(_ observable: Observable<Int>) {
       observable
            .map { ChartRange(rawValue: $0) }.filterNil()
            .map { selectedRange -> Observable<ChartData> in
                if let chartData = self._storedChartData.value.first(where: { $0.range == selectedRange }), chartData.points.isNotEmpty {
                    return .just(chartData)
                } else {
                    return self.stockService
                        .getChartFor(symbol: self._stock.value.quote.symbol,
                                     range: selectedRange.description)
                        .map { ChartData(range: selectedRange, points: $0) }
                }
            }
            .switchLatest()
            .do(onNext: { (chartData) in
                self.updateStoredChartData(chartData)
            })
            .bind(to: _currentChartData)
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
    
    private func updateStoredChartData(_ newChartData: ChartData) {
        guard let index = self._storedChartData.value.index(where: { $0.range == newChartData.range }) else { fatalError("No index for chart range") }
        if self._storedChartData.value[index].points.isEmpty {
            self._storedChartData.value[index].points = newChartData.points
        }
    }
    
}

//    func bindFetchStockDetails(_ observable: Observable<Void>) {
//        observable
//            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInitiated))
//            .map { self._stockSummary.value }
//            .filterNil()
//            .flatMapLatest {
//                self.stockService.getDetailsFor(stockSummary: $0)
//                    .trackNetworkError(self.innerErrorTracker)
//            }
//            .bind(to: _stock)
//            .disposed(by: disposeBag)
//    }




