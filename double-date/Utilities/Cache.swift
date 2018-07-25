//
//  Cache.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/27/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift

protocol Identifiable {
    var _id: String { get }
}

protocol AbstractCache {
    associatedtype T
    func save(object: T) -> Completable
    func save(objects: [T]) -> Completable
    func fetch(withID id: String) -> Maybe<T>
    func fetchObjects() -> Maybe<[T]>
}


final class Cache<T: Codable & Identifiable> {
    
    enum Error: Swift.Error {
        case saveObject(T)
        case saveObjects([T])
        case fetchObject(T.Type)
        case fetchObjects
    }
    
    enum FileNames {
        static var objectFileName: String { return "\(T.self).type" }
        static var objectsFileName: String { return "\(T.self)s.type" }
    }
    
    private let path: String
    private let cacheScheduler = SerialDispatchQueueScheduler(qos: .userInitiated)
    
    init(path: String) {
        self.path = path
    }
    
    func save(objects: [T]) -> Completable {
        return Completable.create { (observer) -> Disposable in
            guard let directoryURL = self.directoryURL() else {
                observer(.completed)
                return Disposables.create()
            }
            let path = directoryURL
                .appendingPathComponent(FileNames.objectsFileName)
            self.createDirectoryIfNeeded(at: directoryURL)
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601)
                try NSKeyedArchiver
                    .archivedData(withRootObject: try! encoder.encode(objects)).write(to: path)
                observer(.completed)
            } catch {
                observer(.error(NetworkError.cacheEncodingError(error)))
            }
            return Disposables.create()
        }.subscribeOn(cacheScheduler)
    }
    
    func save(object: T) -> Completable {
        return Completable.create { (observer) -> Disposable in
            guard let directoryURL = self.directoryURL() else {
                observer(.completed)
                return Disposables.create()
            }
            
            let path = directoryURL
                .appendingPathComponent(FileNames.objectsFileName)
            self.createDirectoryIfNeeded(at: directoryURL)
            
            guard var objects = self.fetchObjectsNonRx() else {
                self.encodeObjects([object], to: path, completion: { (isSuccess) in
                    if isSuccess {
                        observer(.completed)
                    } else {
                        observer(.error(NetworkError.cacheEncodingError(Error.fetchObject(T.self))))
                    }
                })
                return Disposables.create()
            }
            
            objects.append(object)
            
            self.encodeObjects(objects, to: path, completion: { (isSuccess) in
                if isSuccess {
                    observer(.completed)
                } else {
                    observer(.error(NetworkError.cacheEncodingError(Error.fetchObject(T.self))))
                }
            })
            
            return Disposables.create()
        }.subscribeOn(cacheScheduler)
    }
    
    func fetchObjects() -> Maybe<[T]> {
        return Maybe<[T]>.create { (observer) -> Disposable in
            guard let directoryURL = self.directoryURL() else {
                observer(.completed)
                return Disposables.create()
            }
            let fileURL = directoryURL
                .appendingPathComponent(FileNames.objectsFileName)
            guard let data = NSKeyedUnarchiver.unarchiveObject(withFile: fileURL.path) as? Data else {
                observer(.completed)
                return Disposables.create()
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601)
                let objects = try decoder.decode([T].self, from: data)
                print("Retrieved \(objects.count) from cache")
                observer(MaybeEvent.success(objects))
            } catch {
                observer(MaybeEvent.error(NetworkError.cacheDecodingError(error)))
            }
            return Disposables.create()
        }.subscribeOn(cacheScheduler)
    }
    
    private func fetchObjectsNonRx() -> [T]? {
        guard let directoryURL = self.directoryURL() else { return nil }
        let fileURL = directoryURL
            .appendingPathComponent(FileNames.objectsFileName)
        guard let data = NSKeyedUnarchiver.unarchiveObject(withFile: fileURL.path) as? Data else {
            return nil
        }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601)
            return try decoder.decode([T].self, from: data)
        } catch {
            return nil
        }
    }
    
    private func directoryURL() -> URL? {
        return FileManager.default
            .urls(for: .documentDirectory,
                  in: .userDomainMask)
            .first?
            .appendingPathComponent(path)
    }
    
    private func encodeObjects(_ objects: [T], to path: URL, completion: (Bool) -> Void) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601)
            try NSKeyedArchiver
                .archivedData(withRootObject: try! encoder.encode(objects)).write(to: path)
            completion(true)
        } catch {
            completion(false)
        }
    }
    
    private func createDirectoryIfNeeded(at url: URL) {
        do {
            try FileManager.default.createDirectory(at: url,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        } catch {
            print("Cache Error createDirectoryIfNeeded \(error)")
        }
    }
    
}
