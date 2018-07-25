//
//  PhoneEntryViewModel.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/22/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol PhoneEntryViewModelDelegate: BackButtonNavigatable {
    func didEnter(countryCode: String, phoneNumber: String)
}

protocol LoadingTrackable {
    var activityIndicator: ActivityIndicator { get }
    var isLoading: Driver<Bool> { get }
}

struct PhoneEntryViewModel: LoadingTrackable {
    
    //MARK: - Properties
    private let disposeBag = DisposeBag()
    private let numberText = Variable("")
    private let countryCode = Variable("+1")
    private let twilioService = TwilioService()
    private let errorTracker = ErrorTracker()
    let activityIndicator = ActivityIndicator()
    weak var delegate: PhoneEntryViewModelDelegate?
    
    var formattedPhoneNumber: Driver<String> {
        return numberText.asDriver()
            .map { $0.phoneRepresentable() ?? $0 }
    }
    
    var isPhoneNumberValid: Driver<Bool> {
        return numberText.asDriver().map { $0.isPhoneNumber }
    }
    
    var titleHeaderText: Driver<String> {
        return Driver.of("Great, let’s verify your account \nwith a phone number.")
    }
    
    var isLoading: Driver<Bool> {
        return activityIndicator.asDriver(onErrorJustReturn: false)
    }
    
    var error: Driver<NetworkError> {
        return errorTracker.asDriver()
    }
    
    var phoneParams: [String: Any] {
        return [
            "via": "sms",
            "country_code": countryCode.value,
            "phone_number": numberText.value.digits
        ]
    }
    
    //MARK: - Inputs
    func bindTextEntry(_ observable: Observable<String>) {
        observable
            .bind(to: numberText)
            .disposed(by: disposeBag)
    }
    
    func bindContinueButton(_ observable: Observable<Void>) {
        observable
            .flatMapLatest {
                self.twilioService
                    .sendVerificationCode(params: self.phoneParams)
                    .trackNetworkError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
            }
            .subscribe(onNext: { response in
                self.delegate?.didEnter(countryCode: self.countryCode.value,
                                        phoneNumber: self.numberText.value.digits)
            })
            .disposed(by: disposeBag)
    }
    
    func bindClearButton(_ observable: Observable<Void>) {
        observable
            .subscribe(onNext: { self.numberText.value = "" })
            .disposed(by: disposeBag)
    }
    
    func bindBackButton(_ observable: Observable<Void>) {
        observable
            .subscribe(onNext: { self.delegate?.didTapBackButton() })
            .disposed(by: disposeBag)
    }
    
}
