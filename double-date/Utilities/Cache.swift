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
                try NSKeyedArchiver
                    .archivedData(withRootObject: try! JSONEncoder().encode(objects)).write(to: path)
                observer(.completed)
            } catch {
                observer(.error(NetworkError.cacheEncodingError(error)))
            }
            return Disposables.create()
        }
    }
    
    func save(object: T) -> Completable {
        return Completable.create { (observer) -> Disposable in
            guard let url = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask).first else {
                    observer(.completed)
                    return Disposables.create()
            }
            let path = url.appendingPathComponent(self.path)
                .appendingPathComponent("\(object._id)")
                .appendingPathComponent(FileNames.objectFileName)
                .absoluteString
            let encoder = JSONEncoder()
            if NSKeyedArchiver.archiveRootObject(try! encoder.encode(object), toFile: path) {
                observer(.completed)
            } else {
                observer(.error(NetworkError.cacheEncodingError(Error.fetchObject(T.self))))
            }
            
            return Disposables.create()
        }
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
                let objects = try JSONDecoder().decode([T].self, from: data)
                print("Retrieved \(objects.count) from cache")
                observer(MaybeEvent.success(objects))
            } catch {
                observer(MaybeEvent.error(NetworkError.cacheDecodingError(error)))
            }
            return Disposables.create()
        }
    }
    
    private func directoryURL() -> URL? {
        return FileManager.default
            .urls(for: .documentDirectory,
                  in: .userDomainMask)
            .first?
            .appendingPathComponent(path)
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
