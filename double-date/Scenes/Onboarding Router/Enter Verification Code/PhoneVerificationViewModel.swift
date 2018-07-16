//
//  PhoneVerificationViewModel.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/14/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol PhoneVerificationViewModelDelegate: BackButtonNavigatable {
    func didValidateVerificationCode()
}

struct PhoneVerificationViewModel {
    
    //MARK: - Properties
    private let disposeBag = DisposeBag()
    private let verificationCodeText = Variable("")
    private let twilioService = TwilioService()
    let errorTracker = ErrorTracker()
    let activityTracker = ActivityIndicator()
    private let countryCode: String
    private let phoneNumber: String
    weak var delegate: PhoneVerificationViewModelDelegate?
    
    init(countryCode: String, phoneNumber: String) {
        self.countryCode = countryCode
        self.phoneNumber = phoneNumber
    }
    
    var isCodeValid: Driver<Bool> {
        return verificationCodeText.asDriver().map { $0.count == 4 }
    }
    
    var isLoading: Driver<Bool> {
        return activityTracker.asDriver(onErrorJustReturn: false)
    }
    
    var error: Driver<NetworkError> {
        return errorTracker.asDriver()
    }
    
    var titleHeaderText: Driver<VaryingFontInfo> {
        return Driver.of(
            VaryingFontInfo(originalText: "Enter VERIFICATION CODE...", fontDict: ["Enter": FontBook.AvenirMedium.of(size: 14), "VERIFICATION CODE...": FontBook.AvenirHeavy.of(size: 14)], fontColor: .black)
        )
    }
    
    var codeParams: [String: Any] {
        return [
            "country_code": countryCode,
            "phone_number": phoneNumber,
            "verification_code": verificationCodeText.value
        ]
    }
    
    //MARK: - Inputs
    func bindTextEntry(_ observable: Observable<String>) {
        observable
            .bind(to: verificationCodeText)
            .disposed(by: disposeBag)
    }
    
    func bindContinueButton(_ observable: Observable<Void>) {
        observable
            .flatMapLatest {
                self.twilioService.validateVerificationCode(params: self.codeParams)
                    .trackNetworkError(self.errorTracker)
                    .trackActivity(self.activityTracker)
            }
            .subscribe(onNext: {
                guard $0.success else {
                    self.errorTracker._subject.onNext(NetworkError.custom(CustomError(message: $0.message)))
                    return
                }
                self.delegate?.didValidateVerificationCode()
            })
            .disposed(by: disposeBag)
    }
    
    func bindClearButton(_ observable: Observable<Void>) {
        observable
            .subscribe(onNext: { self.verificationCodeText.value = "" })
            .disposed(by: disposeBag)
    }
    
    func bindBackButton(_ observable: Observable<Void>) {
        observable
            .subscribe(onNext: { self.delegate?.didTapBackButton() })
            .disposed(by: disposeBag)
    }
    
}
