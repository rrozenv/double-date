//
//  ErrorTracker.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/13/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ErrorTracker: SharedSequenceConvertibleType {
    typealias SharingStrategy = DriverSharingStrategy
    let _subject = PublishSubject<NetworkError>()
    
    func trackError<O: ObservableConvertibleType>(from source: O) -> Observable<O.E> {
        return source.asObservable().do(onError: onError).catchErrorJustComplete()
    }
    
    func asSharedSequence() -> SharedSequence<SharingStrategy, E> {
        return _subject.asObservable().asDriverOnErrorJustComplete()
    }
    
    func asObservable() -> Observable<NetworkError> {
        return _subject.asObservable()
    }
    
    private func onError(_ error: Error) {
        guard let networkError = error as? NetworkError else {
            _subject.onNext(NetworkError.serverFailed)
            return
        }
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





