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
    
    let network = Network<Fund>(Secrets.baseURL)
    
    func create(params: [String: Any]) -> Observable<Fund> {
        return network.postItem("funds", parameters: params)
    }
    
    func getFunds() -> Observable<[Fund]> {
        return network.getItems("funds")
    }
    
}
