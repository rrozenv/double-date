//
//  ProfileViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/24/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift

final class ProfileViewController: UIViewController, BindableType {
    
    //MARK: - Properties
    let disposeBag = DisposeBag()
    var viewModel: ProfileViewModel!
    
    //MARK: - Views
    private var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        createLogoutButton()
    }
    
    deinit { print("ProfileViewController deinit") }
    
    func bindViewModel() {
        let logoutTapped$ = logoutButton.rx.tap.asObservable()
        viewModel.bindLogoutButton(logoutTapped$)
    }
    
}

extension ProfileViewController {
    
    private func createLogoutButton() {
        logoutButton = UIButton().rxStyle(title: "Logout", font: FontBook.AvenirMedium.of(size: 14), backColor: Palette.aqua.color, titleColor: .white)
        
        view.addSubview(logoutButton)
        logoutButton.snp.makeConstraints { (make) in
            make.left.right.equalTo(view).inset(20)
            make.center.equalTo(view)
            make.height.equalTo(56)
        }
    }
    
}
