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
    
    func getItem(_ path: String, itemId: String) -> Observable<T> {
        let absolutePath = "\(baseUrl)/\(path)/\(itemId)"
        return manager.rx
            .responseData(.get, absolutePath, headers: [Secrets.tokenKeyString: token ?? ""])
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
    
    func postItem(_ path: String, parameters: [String: Any]) -> Observable<T> {
        let absolutePath = "\(baseUrl)/\(path)"
        return manager.rx
            .responseData(.post,
                          absolutePath,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: [Secrets.tokenKeyString: token ?? ""])
            .observeOn(scheduler)
            .mapObject(type: T.self)
    }
    
    func updateItem(_ path: String, itemId: String, parameters: [String: Any]) -> Observable<T> {
        let absolutePath = "\(baseUrl)/\(path)/\(itemId)"
        return RxAlamofire
            .requestData(.put,
                         absolutePath,
                         parameters: parameters,
                         encoding: JSONEncoding.default)
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



//protocol Identifiable {
//    var uid: String { get }
//}
//
//protocol AbstractCache {
//    associatedtype T
//    func save(object: T) -> Completable
//    func save(objects: [T]) -> Completable
//    func fetch(withID id: String) -> Maybe<T>
//    func fetchObjects() -> Maybe<[T]>
//}
//
//final class Cache<T: Encodable>: AbstractCache where T: Identifiable {
//    enum Error: Swift.Error {
//        case saveObject(T)
//        case saveObjects([T])
//        case fetchObject(T.Type)
//        case fetchObjects(T.Type)
//    }
//    enum FileNames {
//        static var objectFileName: String {
//            return "\(T.self).dat"
//        }
//        static var objectsFileName: String {
//            return "\(T.self)s.dat"
//        }
//    }
//
//    private let path: String
//    private let cacheScheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "com.CleanAchitecture.Network.Cache.queue")
//
//    init(path: String) {
//        self.path = path
//    }
//
//    func save(object: T) -> Completable {
//        return Completable.create { (observer) -> Disposable in
//            guard let url = FileManager.default
//                .urls(for: .documentDirectory, in: .userDomainMask).first else {
//                    observer(.completed)
//                    return Disposables.create()
//            }
//            let path = url.appendingPathComponent(self.path)
//                .appendingPathComponent("\(object.uid)")
//                .appendingPathComponent(FileNames.objectFileName)
//                .absoluteString
//
//            if NSKeyedArchiver.archiveRootObject(object.encoder, toFile: path) {
//                observer(.completed)
//            } else {
//                observer(.error(Error.saveObject(object)))
//            }
//
//            return Disposables.create()
//            }.subscribeOn(cacheScheduler)
//    }
//
//    func save(objects: [T]) -> Completable {
//        return Completable.create { (observer) -> Disposable in
//            guard let directoryURL = self.directoryURL() else {
//                observer(.completed)
//                return Disposables.create()
//            }
//            let path = directoryURL
//                .appendingPathComponent(FileNames.objectsFileName)
//            self.createDirectoryIfNeeded(at: directoryURL)
//            do {
//                try NSKeyedArchiver.archivedData(withRootObject: objects.map{ $0.encoder })
//                    .write(to: path)
//                observer(.completed)
//            } catch {
//                observer(.error(error))
//            }
//
//            return Disposables.create()
//            }.subscribeOn(cacheScheduler)
//    }
//
//    func fetch(withID id: String) -> Maybe<T> {
//        return Maybe<T>.create { (observer) -> Disposable in
//            guard let url = FileManager.default
//                .urls(for: .documentDirectory, in: .userDomainMask).first else {
//                    observer(.completed)
//                    return Disposables.create()
//            }
//            let path = url.appendingPathComponent(self.path)
//                .appendingPathComponent("\(id)")
//                .appendingPathComponent(FileNames.objectFileName)
//                .absoluteString
//
//            guard let object = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? T.Encoder else {
//                observer(.completed)
//                return Disposables.create()
//            }
//            observer(MaybeEvent<T>.success(object.asDomain()))
//            return Disposables.create()
//            }.subscribeOn(cacheScheduler)
//    }
//
//    func fetchObjects() -> Maybe<[T]> {
//        return Maybe<[T]>.create { (observer) -> Disposable in
//            guard let directoryURL = self.directoryURL() else {
//                observer(.completed)
//                return Disposables.create()
//            }
//            let fileURL = directoryURL
//                .appendingPathComponent(FileNames.objectsFileName)
//            guard let objects = NSKeyedUnarchiver.unarchiveObject(withFile: fileURL.path) as? [T.Encoder] else {
//                observer(.completed)
//                return Disposables.create()
//            }
//            observer(MaybeEvent.success(objects.map { $0.asDomain() }))
//            return Disposables.create()
//            }.subscribeOn(cacheScheduler)
//    }
//
//    private func directoryURL() -> URL? {
//        return FileManager.default
//            .urls(for: .documentDirectory,
//                  in: .userDomainMask)
//            .first?
//            .appendingPathComponent(path)
//    }
//
//    private func createDirectoryIfNeeded(at url: URL) {
//        do {
//            try FileManager.default.createDirectory(at: url,
//                                                    withIntermediateDirectories: true,
//                                                    attributes: nil)
//        } catch {
//            print("Cache Error createDirectoryIfNeeded \(error)")
//        }
//    }
//}

