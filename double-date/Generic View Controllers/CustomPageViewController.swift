//
//  CustomPageViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/22/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

final class TabControllerDataSource {
    
    private var viewControllers: [UIViewController]
    
    internal init(viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers
    }
    
    internal func indexFor(controller: UIViewController) -> Int? {
        return self.viewControllers.index(of: controller)
    }
    
    internal func controllerFor(index: Int) -> UIViewController? {
        guard index >= 0 && index < self.viewControllers.count else { return nil }
        return self.viewControllers[index]
    }
    
}
