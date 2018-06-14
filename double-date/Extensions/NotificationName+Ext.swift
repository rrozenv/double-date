//
//  NotificationNameExtensions.swift
//  DesignatedHitter
//
//  Created by Robert Rozenvasser on 4/19/18.
//  Copyright © 2018 Blueprint. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

// MARK: - Notification Extension
extension Notification.Name {
    static let createHomeVc = Notification.Name("createHomeVc")
    static let logout = Notification.Name("logout")
    static let userDidUpdate = Notification.Name("userDidUpdate")
    static let changedSubmissionStatusInDetail = Notification.Name("changedSubmissionStatusInDetail")
    static let newNotif = Notification.Name("changedSubmissionStatusInDetail")
}

extension Notification {
    static let gameKey = "game"
}

struct KeyboardWillShowPayload {
    var beginFrame: CGRect
    let endFrame: CGRect
    let animationCurve: UIViewAnimationCurve
    let animationDuration: TimeInterval
    let isLocal: Bool
    init(userInfo: [AnyHashable: Any]) {
        self.beginFrame = userInfo[UIKeyboardFrameBeginUserInfoKey] as! CGRect
        self.endFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
        let animationCurveRaw = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! UIViewAnimationCurve.RawValue
        self.animationCurve = UIViewAnimationCurve(rawValue: animationCurveRaw)!
        self.animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        self.isLocal = userInfo[UIKeyboardIsLocalUserInfoKey] as! Bool
    }
}



