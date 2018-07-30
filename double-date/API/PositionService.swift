//
//  PositionService.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/1/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift

struct PositionService {
    
    private let network = Network<Position>(Secrets.baseURL)
    private let token = MyKeychain.shared.getStringFor(Secrets.tokenKeyString)
    private let cache: Cache = Cache<Position>(path: "positions")
    
    func getAllPositions() -> Observable<[Position]> {
        let cachedPositions = cache.fetchObjects().asObservable()
        let networkPositions = network.getItems("positions", headers: [Secrets.tokenKeyString: token ?? ""])
            .flatMap {
                return self.cache.save(objects: $0)
                    .asObservable()
                    .mapArray(type: Position.self)
                    .concat(Observable.just($0))
            }
        return cachedPositions.concat(networkPositions)
    }
    
    func getPositionsFor(fundId: String) -> Observable<[Position]> {
        return network.getItems("positions/fund/\(fundId)",
            headers: [Secrets.tokenKeyString: token ?? ""])
    }
    
    func closePosition(posId: String, portfolioId: String) -> Observable<Position> {
        return network.updateItem("positions/\(posId)",
                                  itemId: "close",
                                  parameters: ["portfolioId": portfolioId])
    }
    
    func create(params: [String: Any]) -> Observable<Position> {
        return network.postItem("positions", parameters: params)
    }
    
}
