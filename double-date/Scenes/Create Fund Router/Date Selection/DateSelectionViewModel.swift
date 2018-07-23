//
//  DateSelectionViewModel.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/22/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift

struct DateSelectionViewModel {
    
    //MARK: - Properties
    let disposeBag = DisposeBag()
    let selectedDate = Variable<Date>(Date())
    
    //MARK: - Inputs
    func bindDateEntry(_ observable: Observable<Date>) {
        observable
            .bind(to: selectedDate)
            .disposed(by: disposeBag)
    }
    
}
