//
//  UserService.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/13/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import Moya
import RxSwift

struct UserService {
    
    let network = Network<User>(Secrets.baseURL)
    
    func getCurrentUser() -> Observable<User> {
        return network.getItem("users", itemId: "me")
    }
    
    func createUser(params: [String: Any]) -> Observable<User> {
        return network.postItem("users", parameters: params)
    }
    
}

public extension ObservableType where E == Moya.Response {
    
    public func map<T>(to type: T.Type, using decoder: JSONDecoder = JSONDecoder()) -> Observable<T> where T: Swift.Decodable {
        return map {
            try $0.map(type, using: decoder)
        }
    }
    
    public func mapOptional<T>(to type: T.Type, using decoder: JSONDecoder = JSONDecoder()) -> Observable<T?> where T: Swift.Decodable {
        return flatMap { response -> Observable<T?> in
            do {
                return Observable.just(try response.map(to: type, using: decoder))
            } catch {
                return Observable.just(nil)
            }
        }
    }
    
}

public extension Moya.Response {
    
    public func map<T>(to type: T.Type, using decoder: JSONDecoder = JSONDecoder()) throws -> T where T: Swift.Decodable {
        let decoder = decoder
        return try decoder.decode(type, from: data)
    }
    
}
