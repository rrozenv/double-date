//
//  TapPageViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/22/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol TabBarViewable: class {
    var buttons: [UIButton] { get }
}

final class TabPageViewController: UIViewController {
    
    private var dataSource: TabControllerDataSource!
    private var tabView: (UIView & TabBarViewable)!
    private let disposeBag = DisposeBag()
    private var actingVc: UIViewController!
    
    required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder)! }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(viewControllers: [UIViewController], tabView: UIView & TabBarViewable) {
        super.init(nibName: nil, bundle: nil)
        self.tabView = tabView
        self.dataSource = TabControllerDataSource(viewControllers: viewControllers)
    }
    
    deinit { print("TabPageViewController deinit") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        view.backgroundColor = UIColor.white
        self.actingVc = dataSource.controllerFor(index: 0)!
        self.addChild(self.actingVc, frame: self.view.frame, animated: true, belowView: tabView)
        setupTabOptionsView()
        setupTabButtonBindings()
    }
    
    func setupTabButtonBindings() {
        tabView.buttons.forEach { button in
            button.rx.tap.asObservable().map { button.tag }
                //.distinctUntilChanged()
                .subscribe(onNext: { [unowned self] in
                    guard let vc = self.dataSource.controllerFor(index: $0) else { fatalError() }
                    self.transiton(to: vc)
                })
                .disposed(by: disposeBag)
        }
    }
    
}

extension TabPageViewController {
    
    private func setupTabOptionsView() {
        view.addSubview(tabView)
        tabView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
        }
    }
    
    private func transiton(to vc: UIViewController) {
        self.removeChild(actingVc, completion: nil)
        self.actingVc = vc
        self.addChild(self.actingVc, frame: self.view.frame, animated: true, belowView: tabView)
    }
    
}
