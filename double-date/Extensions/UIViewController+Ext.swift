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
    
    func addChild(_ viewController: UIViewController, frame: CGRect?, animated: Bool) {
        self.addChildViewController(viewController)
        self.view.addSubview(viewController.view)
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

