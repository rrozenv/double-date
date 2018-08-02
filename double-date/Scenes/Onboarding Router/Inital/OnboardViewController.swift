//
//  OnboardViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 8/2/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SnapKit

struct OnboardInfo {
    let pageNumber: Int
    let header: String
    let body: String
    let buttonTitle: String
}

extension OnboardInfo {
    static var initalOnboardingInfo: [OnboardInfo] {
        let page0 = OnboardInfo(pageNumber: 0,
                                   header: "This is the first page",
                                   body: "This is the first body",
                                   buttonTitle: "Button 1")
        let page1 = OnboardInfo(pageNumber: 1,
                                   header: "This is the second page",
                                   body: "This is the second body",
                                   buttonTitle: "Button 2")
        let page2 = OnboardInfo(pageNumber: 2,
                                header: "This is the third page",
                                body: "This is the third body",
                                buttonTitle: "Button 3")
        return [page0, page1, page2]
    }
}

protocol Animatable {
    func animate()
    func resetAnimation()
}

class AnimatableViewController: UIViewController, Animatable {
    func animate() { }
    func resetAnimation() { }
}

final class OnboardViewController: AnimatableViewController {
    
    let disposeBag = DisposeBag()
    var viewModel: InitialViewModel!
    var onboardInfo: Variable<OnboardInfo>!
    private var headerLabel: UILabel!
    private var bodyLabel: UILabel!
    private let widthMultiplier = 0.74
    private var centerStackConstraint: Constraint!
    private var stackConstraint: NSLayoutConstraint!
    
    static func configuredWith(info: OnboardInfo) -> OnboardViewController {
        let vc = OnboardViewController()
        vc.onboardInfo = Variable(info)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .random
        setupLabels()
        bindViewModel()
        //resetAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stackConstraint.constant -= self.view.frame.width
    }
    
    deinit { print("Onboaridng deinit") }
    
    override func animate() {
        self.stackConstraint.constant += view.frame.width
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.curveEaseOut], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    override func resetAnimation() {
//        self.stackConstraint.constant -= view.frame.width
//        self.view.layoutIfNeeded()
    }
    
    func bindViewModel() {
        onboardInfo.asDriver()
            .drive(onNext: { [weak self] in
                self?.headerLabel.text = $0.header
                self?.bodyLabel.text = $0.body
            })
            .disposed(by: disposeBag)
    }
    
    private func setupLabels() {
        headerLabel = UILabel().rxStyle(font: FontBook.AvenirHeavy.of(size: 14), color: .black, alignment: .left)
        bodyLabel = UILabel().rxStyle(font: FontBook.AvenirHeavy.of(size: 14), color: .black, alignment: .left)
        let stackView = UIStackView(arrangedSubviews: [headerLabel, bodyLabel])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 10.0
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self.stackConstraint = stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        self.stackConstraint.isActive = true
        self.stackConstraint.constant -= self.view.frame.width
    }
    
}

//    override func viewDidAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        print("View appeared!")
//        animate()
//        //resetAnimation()
//    }
//
////    override func viewDidAppear(_ animated: Bool) {
////        super.viewDidAppear(animated)
////        animate()
////    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        print("View disappered!")
//        resetAnimation()
//    }
