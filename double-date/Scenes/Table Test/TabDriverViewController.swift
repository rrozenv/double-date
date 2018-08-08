//
//  TabDriverViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 8/8/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

final class TabDriverViewController: UIViewController {
    
    private var dataSource: TabControllerDataSource!
    private var actingVc: UIViewController?
    
    required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder)! }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(viewControllers: [UIViewController]) {
        super.init(nibName: nil, bundle: nil)
        self.dataSource = TabControllerDataSource(viewControllers: viewControllers)
        self.actingVc = dataSource.controllerFor(index: 0) 
    }
    
    deinit { print("TabDriverViewController deinit") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addChild(self.actingVc!, frame: self.view.frame, animated: false)
    }
    
    func transitionToController(at index: Int) {
        guard let vc = dataSource.controllerFor(index: index) else { return }
        self.transiton(to: vc)
    }
    
}

extension TabDriverViewController {
    
    private func transiton(to vc: UIViewController) {
        self.removeChild(actingVc!, completion: nil)
        self.actingVc = vc
        self.addChild(self.actingVc!, frame: self.view.frame, animated: true)
    }
    
}
