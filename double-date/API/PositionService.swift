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
    
    func create(params: [String: Any]) -> Observable<Position> {
        return network.postItem("positions", parameters: params)
    }
    
}
