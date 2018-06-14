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
    
    let provider = MoyaProvider<API>()
    
//    func allUsers() -> Observable<[User]> {
//        return provider.rx
//            .request(.users(.allUsers)).asObservable()
//            .map(to: [User.self])
//    }
    
    func getCurrentUser() -> Observable<User> {
        return provider.rx
            .request(.users(.me)).asObservable()
            .map(User.self)
    }
    
    func create(user: JSONDictionary) -> Observable<User> {
        return provider.rx
            .request(.users(.createUser(user))).asObservable()
            .do(onNext: { response in
                let urlResponse = response.response
                guard let token = urlResponse?.allHeaderFields["x-auth-token"] as? String else {
                    return
                }
                print("token: \(token)")
            })
            .map(User.self)
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
