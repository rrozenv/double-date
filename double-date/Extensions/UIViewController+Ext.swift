//
//  ChildViewControllerManager.swift
//  DesignatedHitter
//
//  Created by Robert Rozenvasser on 4/20/18.
//  Copyright © 2018 Blueprint. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func addChild(_ viewController: UIViewController, frame: CGRect?, animated: Bool, belowView: UIView? = nil) {
        self.addChildViewController(viewController)
        if let belowView = belowView {
            self.view.insertSubview(viewController.view, belowSubview: belowView)
        } else {
            self.view.addSubview(viewController.view)
        }
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParentViewController: self)
        if let frame = frame { viewController.view.frame = frame }
        
        guard animated else { view.alpha = 1.0; return }
        UIView.transition(with: view, duration: 0.5, options: .curveEaseIn, animations: {
            self.view.alpha = 1.0
        }) { _ in }
    }
    
    func removeChild(_ viewController: UIViewController, completion: (() -> Void)?) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
        if completion != nil { completion!() }
    }
    
}

extension UIViewController {
    
    func resignKeyboardOnViewTouch() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(resignKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func resignKeyboard() {
        view.endEditing(true)
    }
    
}

extension UIViewController {
    
    func displayNetworkError(_ error: NetworkError) {
        var alertInfo: AlertViewController.AlertInfo?
        switch error {
        case .custom(let info):
            alertInfo = AlertViewController.AlertInfo.custom(error: info)
        case .decodingError:
            alertInfo = AlertViewController.AlertInfo.decodingError
        case .serverFailed:
            alertInfo = AlertViewController.AlertInfo.serverFailed
        case .cacheDecodingError(let error):
            debugPrint(error)
        case .cacheEncodingError(let error):
            debugPrint(error)
        }
        guard let info = alertInfo else { return }
        let alertVc = AlertViewController(alertInfo: info, okAction: nil)
        alertVc.modalPresentationStyle = .overCurrentContext
        self.present(alertVc, animated: true, completion: nil)
    }
    
}

