//
//  Network.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/14/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import Alamofire
import RxAlamofire
import RxSwift
import KeychainAccess

final class Network<T: Codable> {
    
    private let baseUrl: String
    private let scheduler: ConcurrentDispatchQueueScheduler
    private let manager = SessionManager.default
    private let token: String?
    
    init(_ baseUrl: String) {
        self.baseUrl = baseUrl
        self.token = MyKeychain.shared.getStringFor(Secrets.tokenKeyString)
        self.scheduler = ConcurrentDispatchQueueScheduler(qos: DispatchQoS(qosClass: DispatchQoS.QoSClass.background, relativePriority: 1))
    }
    
    func getItems(_ path: String,
                  parameters: [String: Any]? = nil,
                  encoding: ParameterEncoding = JSONEncoding.default,
                  headers: [String: String]? = nil) -> Observable<[T]> {
        let absolutePath = "\(baseUrl)/\(path)"
        return RxAlamofire
            .requestData(.get, absolutePath, parameters: parameters, encoding: encoding, headers: headers)
            .observeOn(scheduler)
            .mapArray(type: T.self)
    }
    
    func getItem(_ path: String,
                 parameters: [String: Any]? = nil,
                 encoding: ParameterEncoding = JSONEncoding.default,
                 itemId: String,
                 headers: [String: String] = [Secrets.tokenKeyString: MyKeychain.shared.getStringFor(Secrets.tokenKeyString) ?? ""]) -> Observable<T> {
        let absolutePath = "\(baseUrl)/\(path)/\(itemId)"
        return manager.rx
            .responseData(.get, absolutePath, parameters: parameters, encoding: encoding, headers: headers)
            .observeOn(scheduler)
            .mapObject(type: T.self)
    }
    
    func getOptionalItem(_ path: String, itemId: String) -> Observable<T?> {
        let absolutePath = "\(baseUrl)/\(path)/\(itemId)"
        return manager.rx
            .responseData(.get, absolutePath)
            .observeOn(scheduler)
            .mapOptionalObject(type: T.self)
    }
    
    func postItem(_ path: String,
                  parameters: [String: Any],
                  headers: [String: String] = [Secrets.tokenKeyString: MyKeychain.shared.getStringFor(Secrets.tokenKeyString) ?? ""]) -> Observable<T> {
        let absolutePath = "\(baseUrl)/\(path)"
        return manager.rx
            .responseData(.post,
                          absolutePath,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: headers)
            .observeOn(scheduler)
            .mapObject(type: T.self)
    }
    
    func updateItem(_ path: String,
                    itemId: String,
                    parameters: [String: Any] = [:],
                    headers: [String: String] = [Secrets.tokenKeyString: MyKeychain.shared.getStringFor(Secrets.tokenKeyString) ?? ""]) -> Observable<T> {
        let absolutePath = "\(baseUrl)/\(path)/\(itemId)"
        return RxAlamofire
            .requestData(.put,
                         absolutePath,
                         parameters: parameters,
                         encoding: JSONEncoding.default,
                         headers: headers)
            .observeOn(scheduler)
            .mapObject(type: T.self)
    }
    
    func deleteItem(_ path: String, itemId: String) -> Observable<T> {
        let absolutePath = "\(baseUrl)/\(path)/\(itemId)"
        return RxAlamofire
            .requestData(.delete, absolutePath)
            .observeOn(scheduler)
            .mapObject(type: T.self)
    }
    
}

extension Network where T == User {
    
    func postUser(_ path: String, parameters: [String: Any]) -> Observable<T> {
        let absolutePath = "\(baseUrl)/\(path)"
        print(parameters)
        return manager.rx
            .responseData(.post, absolutePath,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
            .do(onNext: { response, _ in
                guard let token = response.allHeaderFields[Secrets.tokenKeyString] as? String else {
                    return
                }
                let saved = MyKeychain.shared.save(value: token, key: Secrets.tokenKeyString)
                if saved { print("Auth token was saved...") }
            })
            .observeOn(scheduler)
            .mapObject(type: T.self)
    }
    
}





