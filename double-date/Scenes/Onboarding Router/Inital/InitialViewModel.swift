//
//  InitialViewModel.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/13/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol InitalViewModelDelegate: class {
    func didTapContinueButton()
    func didTapLogInButton()
}

struct InitialViewModel {
    
    let disposeBag = DisposeBag()
    weak var delegate: InitalViewModelDelegate?
    
    //MARK: - Init
    init() {
        //MARK: - Outputs
    }
    
    func bindContinueButton(_ observable: Observable<Void>) {
        observable
            .subscribe(onNext: { self.delegate?.didTapContinueButton() })
            .disposed(by: disposeBag)
    }
    
    func bindLogInButton(_ observable: Observable<Void>) {
        observable
            .subscribe(onNext: { self.delegate?.didTapLogInButton() })
            .disposed(by: disposeBag)
    }
    
}
