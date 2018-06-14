//
//  KeyboardAvoidable.swift
//  HousePartyApp
//
//  Created by Robert Rozenvasser on 5/12/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift

protocol KeyboardAvoidable: class {
    var disposeBag: DisposeBag { get }
    var latestKeyboardHeight: CGFloat { get set }
    var adjustableConstraint: Constraint! { get set }
    func bindKeyboardNotifications(bottomOffset: CGFloat)
}

extension KeyboardAvoidable where Self: UIViewController {
    func bindKeyboardNotifications(bottomOffset: CGFloat = 0.0) {
        UIDevice.keyboardHeightWillChange
            .subscribe(onNext: { [weak self] height in
                guard let sSelf = self else { return }
                if sSelf.latestKeyboardHeight > CGFloat(0.0) && height != CGFloat(0.0) { return }
                sSelf.adjustableConstraint.update(offset: -height - bottomOffset)
                UIView.animate(withDuration: 0.5) { sSelf.view.layoutIfNeeded() }
                sSelf.latestKeyboardHeight = height
            })
            .disposed(by: disposeBag)
    }
}
