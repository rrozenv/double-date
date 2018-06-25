//
//  ProfileViewModel.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/24/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ProfileViewModelDelegate: class {
    func didTapLogoutButton()
}

struct ProfileViewModel {
    
    let disposeBag = DisposeBag()
    weak var delegate: ProfileViewModelDelegate?
    
    //MARK: - Init
    init() {
        //MARK: - Outputs
    }
    
    func bindLogoutButton(_ observable: Observable<Void>) {
        observable
            .subscribe(onNext: {
                let _ = MyKeychain.shared.removeAllValues()
                self.delegate?.didTapLogoutButton()
            })
            .disposed(by: disposeBag)
    }
    
}
