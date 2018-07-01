//
//  FundService.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/24/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift

struct FundService {
    
    private let network = Network<Fund>(Secrets.baseURL)
    private let token = MyKeychain.shared.getStringFor(Secrets.tokenKeyString)
    private let cache: Cache = Cache<Fund>(path: "funds")
    
    func create(params: [String: Any]) -> Observable<Fund> {
        return network.postItem("funds", parameters: params)
            .flatMap {
                return self.cache.save(object: $0)
                    .asObservable()
                    .mapObject(type: Fund.self)
                    .concat(Observable.just($0))
            }
    }
    
    func getFunds() -> Observable<[Fund]> {
        let cachedFunds = cache.fetchObjects().asObservable()
        let networkFunds = network.getItems("funds", headers: [Secrets.tokenKeyString: token ?? ""])
            .flatMap {
                return self.cache.save(objects: $0)
                    .asObservable()
                    .mapArray(type: Fund.self)
                    .concat(Observable.just($0))
            }
        return cachedFunds.concat(networkFunds)
    }
    
}
