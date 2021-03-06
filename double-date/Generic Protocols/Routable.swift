//
//  Routable.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/13/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

protocol Navigateable: class {
    var navVc: UINavigationController { get }
}

protocol Routable: Navigateable {
    associatedtype Screen
    var navVc: UINavigationController { get }
    var screenOrder: [Screen] { get }
    var screenIndex: Int { get set }
    func navigateTo(screen: Screen)
    func toPreviousScreen(completion: (() -> Void)?)
    func toNextScreen()
}

extension Routable {
    
    func toNextScreen() {
        guard screenIndex < screenOrder.count - 1 else {
            print("No more screens") ; return
        }
        screenIndex += 1
        navigateTo(screen: screenOrder[screenIndex])
    }
    
    func toPreviousScreen(completion: (() -> Void)? = nil) {
        guard screenIndex != 0 else {
            navVc.dismiss(animated: true, completion: completion)
            return
        }
        screenIndex -= 1
        navVc.popViewController(animated: true)
        completion?()
    }
    
    func displayAlert(vc: AlertViewController)  {
        DispatchQueue.main.async {
            vc.modalPresentationStyle = .overCurrentContext
            self.navVc.present(vc, animated: true, completion: nil)
        }
    }
    
}
