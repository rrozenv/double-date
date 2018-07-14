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

protocol PhoneVerificationViewModelDelegate: class {
    func didValidateVerificationCode()
}

struct PhoneVerificationViewModel {
    
    //MARK: - Properties
    private let disposeBag = DisposeBag()
    private let verificationCodeText = Variable("")
    private let twilioService = TwilioService()
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
            }
            .subscribe(onNext: {
                print($0)
                self.delegate?.didValidateVerificationCode()
            })
            .disposed(by: disposeBag)
    }
    
    func bindClearButton(_ observable: Observable<Void>) {
        observable
            .subscribe(onNext: { self.verificationCodeText.value = "" })
            .disposed(by: disposeBag)
    }
    
//    func bindBackButton(_ observable: Observable<Void>) {
//        observable
//            .subscribe(onNext: { self.coordinator.toPreviousScreen() })
//            .disposed(by: disposeBag)
//    }
}
