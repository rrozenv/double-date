//
//  StockService.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/26/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct StockService {
    
    let iexStockNetwork = Network<Stock>(Secrets.iexBaseURL)
    let iexChartNetwork = Network<ChartPoint>(Secrets.iexBaseURL)
    let myNetwork = Network<StockSummary>(Secrets.baseURL)

    func getPopularStocks() -> Observable<[StockSummary]> {
        return myNetwork.getItems("stocks/search",
                                  parameters: ["isExact": true, "query": "aapl,fb,tsla"],
                                  encoding: URLEncoding.queryString)
    }
    
    func getStockFor(query: String) -> Observable<[StockSummary]> {
        return myNetwork.getItems("stocks/search",
                                  parameters: ["query": query],
                                  encoding: URLEncoding.queryString)
    }
    
    func getDetailsFor(stockSummary: StockSummary) -> Observable<Stock> {
        return iexStockNetwork.getItem("stock",
                                  parameters:  ["types": "quote,news,chart", "range": "1d"],
                                  encoding: URLEncoding.default,
                                  itemId: "\(stockSummary.symbol)/batch")
    }
    
    func getChartFor(symbol: String, range: String) -> Observable<[ChartPoint]> {
        return iexChartNetwork.getItems("stock/\(symbol)/chart/\(range)")
    }
    
}

//    func getPopularStocks() -> Observable<[Stock]> {
//        return iexNetwork.getItems("stocks",
//                      parameters: ["types": "quote", "symbols": "aapl,fb"],
//                      encoding: URLEncoding.queryString)
//    }

