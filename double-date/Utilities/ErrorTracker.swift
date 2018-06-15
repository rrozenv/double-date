//
//  ErrorTracker.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/13/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxAlamofire
import Alamofire
//import RxSwift
//import RxCocoa
//
//final class ErrorTracker<E: Error>: SharedSequenceConvertibleType {
//    typealias SharingStrategy = DriverSharingStrategy
//    private let _subject = PublishSubject<E>()
//
//    func trackError<O: ObservableConvertibleType>(from source: O) -> Observable<O.E> {
//        return source.asObservable().do(onNext: {
//            self.onError(($0 as? E)!)
//        })
//    }
//
//    func asSharedSequence() -> SharedSequence<SharingStrategy, E> {
//        return _subject.asObservable().asDriverOnErrorJustComplete()
//    }
//
//    func asObservable() -> Observable<E> {
//        return _subject.asObservable()
//    }
//
//    private func onError(_ error: E) {
//        _subject.onNext(error)
//    }
//
//    deinit {
//        _subject.onCompleted()
//    }
//}
//
//extension ObservableConvertibleType {
//    func trackError(_ errorTracker: ErrorTracker<CustomError>) -> Observable<E> {
//        return errorTracker.trackError(from: self)
//    }
//}

import RxSwift
import RxCocoa

//final class ErrorTracker: SharedSequenceConvertibleType {
//    typealias SharingStrategy = DriverSharingStrategy
//    private let _subject = PublishSubject<Error>()
//
//    func trackError<O: ObservableConvertibleType>(from source: O) -> Observable<O.E> {
//        return source.asObservable().do(onError: onError)
//    }
//
//    func asSharedSequence() -> SharedSequence<SharingStrategy, Error> {
//        return _subject.asObservable().asDriverOnErrorJustComplete()
//    }
//
//    func asObservable() -> Observable<Error> {
//        return _subject.asObservable()
//    }
//
//    private func onError(_ error: Error) {
//        _subject.onNext(error)
//    }
//
//    deinit {
//        _subject.onCompleted()
//    }
//}


final class ErrorTracker: SharedSequenceConvertibleType {
    typealias SharingStrategy = DriverSharingStrategy
    private let _subject = PublishSubject<NetworkError>()
    
    func trackError<O: ObservableConvertibleType>(from source: O) -> Observable<O.E> {
        return source.asObservable().do(onError: onError)
    }
    
    func asSharedSequence() -> SharedSequence<SharingStrategy, E> {
        return _subject.asObservable().asDriverOnErrorJustComplete()
    }
    
    func asObservable() -> Observable<NetworkError> {
        return _subject.asObservable()
    }
    
    private func onError(_ error: Error) {
        let networkError = error as! NetworkError
        _subject.onNext(networkError)
    }
    
    deinit {
        _subject.onCompleted()
    }
}

extension ObservableType {
    func trackNetworkError(_ errorTracker: ErrorTracker) -> Observable<E> {
        return errorTracker.trackError(from: self)
    }
}

extension ObservableType where E == (HTTPURLResponse, Data) {
    
    func logRequest() -> Self {
        return self.do(onNext: { (response, data) in
            debugPrint(response.debugDescription)
        }) as! Self
    }
    
}

extension ObservableType where E == DataRequest {
    
    func logRequest() -> Self {
        return self.do(onNext: { (request) in
            print(request.request?.url ?? "")
            
        }) as! Self
    }
    
}

extension ObservableType where E == Request {
    public func debugLog() -> Self {
        #if DEBUG
            debugPrint(self)
        #endif
        return self
    }
}




