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

protocol PhoneEntryViewModelDelegate: class {
    func didEnter(countryCode: String, phoneNumber: String)
}

struct PhoneEntryViewModel {
    
    //MARK: - Properties
    private let disposeBag = DisposeBag()
    private let numberText = Variable("")
    private let countryCode = Variable("+1")
    private let twilioService = TwilioService()
    private let errorTracker = ErrorTracker()
    weak var delegate: PhoneEntryViewModelDelegate?
    
    var formattedPhoneNumber: Driver<String> {
        return numberText.asDriver()
            .map { $0.phoneRepresentable() ?? $0 }
    }
    
    var isPhoneNumberValid: Driver<Bool> {
        return numberText.asDriver().map { $0.isPhoneNumber }
    }
    
    var titleHeaderText: Driver<VaryingFontInfo> {
        return Driver.of(
            VaryingFontInfo(originalText: "What's your PHONE NUMBER?", fontDict: ["What's your": FontBook.AvenirMedium.of(size: 14), "PHONE NUMBER?": FontBook.AvenirHeavy.of(size: 14)], fontColor: .black)
        )
    }
    
    var phoneParams: [String: Any] {
        return [
            "via": "sms",
            "country_code": countryCode.value,
            "phone_number": numberText.value
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
            }
            .subscribe(onNext: { response in
                self.delegate?.didEnter(countryCode: self.countryCode.value,
                                        phoneNumber: self.numberText.value)
            })
            .disposed(by: disposeBag)
    }
    
    func bindClearButton(_ observable: Observable<Void>) {
        observable
            .subscribe(onNext: { self.numberText.value = "" })
            .disposed(by: disposeBag)
    }
    
//    func bindBackButton(_ observable: Observable<Void>) {
//        observable
//            .subscribe(onNext: { self.coordinator.toPreviousScreen() })
//            .disposed(by: disposeBag)
//    }
    
}
