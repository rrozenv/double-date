//
//  Observable+Ext.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/13/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension ObservableType where E == Bool {
    /// Boolean not operator
    public func not() -> Observable<Bool> {
        return self.map(!)
    }
    
}

extension SharedSequenceConvertibleType {
    func mapToVoid() -> SharedSequence<SharingStrategy, Void> {
        return map { _ in }
    }
}

extension ObservableType {
    
    func catchErrorJustComplete() -> Observable<E> {
        return catchError { _ in
            return Observable.empty()
        }
    }
    
    func asDriverOnErrorJustComplete() -> Driver<E> {
        return asDriver { error in
            return Driver.empty()
        }
    }
    
    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
}

struct CustomError: Error, Codable {
    let message: String
}

enum NetworkError: Error, CustomStringConvertible {
   case serverFailed
   case decodingError
   case custom(CustomError)
    
    var description: String {
        switch self {
        case .custom(let err):
            return err.message
        case .serverFailed: return "Server failed"
        case .decodingError: return "Decoding error"
        }
    }
}

extension ObservableType {
    
    public func mapObject<T: Codable>(type: T.Type) -> Observable<T> {
        return flatMap { data -> Observable<T> in
            let responseTuple = data as? (HTTPURLResponse, Data)

            guard let jsonData = responseTuple?.1 else {
                throw NSError(
                    domain: "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Could not decode object"]
                )
            }
            
            let decoder = JSONDecoder()
            
            do {
                let object = try decoder.decode(T.self, from: jsonData)
                return Observable.just(object)
            } catch {
                do {
                    let error = try decoder.decode(CustomError.self, from: jsonData)
                    return Observable.error(NetworkError.custom(error))
                } catch {
                    return Observable.error(NetworkError.decodingError)
                }
            }
            
        }
    }
    
    public func mapOptionalObject<T: Codable>(type: T.Type) -> Observable<T?> {
        return flatMap { data -> Observable<T?> in
            let responseTuple = data as? (HTTPURLResponse, Data)
            
            guard let jsonData = responseTuple?.1 else {
                throw NSError(
                    domain: "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Could not decode object"]
                )
            }
            
            let decoder = JSONDecoder()
            
            do {
                let object = try decoder.decode(T.self, from: jsonData)
                return Observable.just(object)
            } catch {
                return Observable.just(nil)
            }
            
        }
    }
    
    public func mapArray<T: Codable>(type: T.Type) -> Observable<[T]> {
        return flatMap { data -> Observable<[T]> in
            let responseTuple = data as? (HTTPURLResponse, Data)
            
            guard let jsonData = responseTuple?.1 else {
                throw NSError(
                    domain: "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Could not decode object"]
                )
            }
            
            let decoder = JSONDecoder()
            
            do {
                let objects = try decoder.decode([T].self, from: jsonData)
                return Observable.just(objects)
            } catch {
                do {
                    let error = try decoder.decode(CustomError.self, from: jsonData)
                    return Observable.error(error)
                } catch {
                    return Observable.error(NetworkError.decodingError)
                }
            }
            
        }
    }
}

