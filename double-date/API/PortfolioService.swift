//
//  PortfolioService.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/3/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct PortfolioService {
    
    private let network = Network<Portfolio>(Secrets.baseURL)
    private let token = MyKeychain.shared.getStringFor(Secrets.tokenKeyString)
    private let cache: Cache<Portfolio>
    
    init(fundId: String) {
        self.cache = Cache<Portfolio>(path: "portfolios/\(fundId)")
    }
    
    func getPortfoliosFor(ids: [String]) -> Observable<[Portfolio]> {
        let cachedPorts = cache.fetchObjects().asObservable()
        let networkPorts = network
            .getItems("portfolios",
                      parameters: ["ids": ids.joined(separator: ",")],
                      encoding: URLEncoding.queryString,
                      headers: [Secrets.tokenKeyString: token ?? ""])
            .flatMap {
                return self.cache.save(objects: $0)
                    .asObservable()
                    .mapArray(type: Portfolio.self)
                    .concat(Observable.just($0))
            }
        return cachedPorts.concat(networkPorts)
    }
    
}
