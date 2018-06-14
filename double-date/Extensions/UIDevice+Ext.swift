//
//  UIDevice+Ext.swift
//  HousePartyApp
//
//  Created by Robert Rozenvasser on 5/12/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

extension UIDevice {
    static var iPhoneX: Bool { return UIScreen.main.nativeBounds.height == 2436 }
    static var keyboardHeightWillChange: Observable<CGFloat> {
        let keyBoardWillShow$ = NotificationCenter.default
            .rx.notification(NSNotification.Name.UIKeyboardWillShow)
            .map { KeyboardWillShowPayload(userInfo: $0.userInfo!).endFrame.height }
        let keyBoardWillHide$ = NotificationCenter.default
            .rx.notification(NSNotification.Name.UIKeyboardWillHide)
            .map { _ in CGFloat(0) }
        return Observable.of(keyBoardWillShow$, keyBoardWillHide$)
            .merge()
            .distinctUntilChanged()
    }
}
