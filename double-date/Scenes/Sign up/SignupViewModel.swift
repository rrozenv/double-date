//
//  SignupViewModel.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/14/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import GoogleSignIn

final class SignupViewModel {
    
    let disposeBag = DisposeBag()
    weak var delegate: InitalViewModelDelegate?
    
    //MARK: - Init
    init() {
       
    }
    
    func bindContinueButton(_ observable: Observable<Void>) {
        observable
            .subscribe(onNext: { [weak self] in self?.delegate?.didTapContinueButton() })
            .disposed(by: disposeBag)
    }
    
}


