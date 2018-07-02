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
    
    let network = Network<Stock>(Secrets.baseURL)

    func getStocks() -> Observable<[Stock]> {
        return network.getItems("stocks",
                                parameters: ["types": "quote", "symbols": "aapl,fb"],
                                encoding: URLEncoding.queryString)
    }
    
}
