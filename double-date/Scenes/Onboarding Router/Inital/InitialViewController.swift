//
//  InitialViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/13/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation

import UIKit
import RxSwift

final class InitialViewController: UIViewController, BindableType {
    
    //MARK: - Properties
    let disposeBag = DisposeBag()
    var viewModel: InitialViewModel!
    
    //MARK: - Views
    private var continueButton: UIButton!
    private var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        createContinueButton()
        createLogInButton()
    }
    
    deinit { print("InitialViewController deinit") }
    
    func bindViewModel() {
        let continueTapped$ = continueButton.rx.tap.asObservable()
        viewModel.bindContinueButton(continueTapped$)
        
        let loginTapped$ = loginButton.rx.tap.asObservable()
        viewModel.bindLogInButton(loginTapped$)
    }

}

extension InitialViewController {
    
    private func createContinueButton() {
        continueButton = UIButton().rxStyle(title: "Continue", font: FontBook.AvenirMedium.of(size: 14), backColor: Palette.aqua.color, titleColor: .white)
        
        view.addSubview(continueButton)
        continueButton.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(56)
        }
    }
    
    private func createLogInButton() {
        loginButton = UIButton().rxStyle(title: "Log In", font: FontBook.AvenirMedium.of(size: 14), backColor: Palette.purple.color, titleColor: .white)
        
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.bottom.equalTo(continueButton.snp.top)
            make.height.equalTo(56)
        }
    }
    
}
