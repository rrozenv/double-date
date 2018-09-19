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
    func adjustButtonStyle(selected tag: Int)
}

final class TabPageViewController: UIViewController {
    
    private var dataSource: TabControllerDataSource!
    private let userService = UserService()
    private let errorTracker = ErrorTracker()
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
        AppController.shared.user$.asObservable()
            .filter { $0 == nil }
            .flatMapLatest { [unowned self] _ in
                self.userService.getCurrentUser()
                    .trackNetworkError(self.errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .subscribe(onNext: {
                print("Feteched user: \($0)")
                AppController.shared.setCurrentUser($0)
            })
            .disposed(by: disposeBag)
        
        errorTracker.asDriver()
            .drive(onNext: { _ in
                print("Recieved fetch user error")
            })
            .disposed(by: disposeBag)
        
        tabView.buttons.forEach { button in
            button.rx.tap.asObservable().map { button.tag }
                .subscribe(onNext: { [unowned self] in
                    guard let vc = self.dataSource.controllerFor(index: $0) else { fatalError() }
                    self.transiton(to: vc)
                    self.tabView.adjustButtonStyle(selected: $0)
                })
                .disposed(by: disposeBag)
        }
    }
    
}

extension TabPageViewController {
    
    private func setupTabOptionsView() {
        tabView.dropShadow()
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
