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
            .flatMap { ports in
                return self.cache.save(objects: ports)
                    .asObservable()
                    .map { _ in ports }
                    //.mapArray(type: Portfolio.self)
            }
        return cachedPorts.concat(networkPorts)
    }
    
}
