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
    var screenOrder: [Screen] { get }
    var screenIndex: Int { get set }
    func navigateTo(screen: Screen)
    func toPreviousScreen()
    func toNextScreen()
}

extension Routable {
    
    func toNextScreen() {
        print("going to next screen")
        print("Index \(screenIndex)")
        print("Order \(screenOrder.count - 1)")
        guard screenIndex < screenOrder.count - 1 else {
            print("No more screens") ; return
        }
        screenIndex += 1
        navigateTo(screen: screenOrder[screenIndex])
    }
    
    func toPreviousScreen() {
        guard screenIndex != 0 else {
            print("This is the first screen")
            navVc.dismiss(animated: true, completion: nil)
            return
        }
        screenIndex -= 1
        print("New Index \(screenIndex)")
        navVc.popViewController(animated: true)
    }
    
    func displayAlert(vc: AlertViewController)  {
        vc.modalPresentationStyle = .overCurrentContext
        navVc.present(vc, animated: true, completion: nil)
    }
    
}
