//
//  SignupViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/14/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import GoogleSignIn

protocol SignupViewControllerDelegate: class {
    func didCreateUser()
}

final class SignupViewController: UIViewController {
    
    //MARK: - Props
    let disposeBag = DisposeBag()
    weak var delegate: SignupViewControllerDelegate?
    
    //MARK: - Private Props
    private let errorTracker = ErrorTracker()
    private let userService = UserService()
    
    //MARK: - Views
    private var googleButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        GIDSignIn.sharedInstance().clientID = Secrets.googleClientID
        GIDSignIn.sharedInstance().delegate = self
        setupGoogleButton()
    }
    
    deinit { print("SignupViewController deinit") }
    
    func bindViewModel() {
        errorTracker.asDriver()
            .drive(onNext: {
                print("Error: \($0)")
            })
            .disposed(by: disposeBag)
    }
    
}

extension SignupViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            print(userId ?? "No id")
            print(idToken ?? "No token")
            print(fullName ?? "No full name")
            print(givenName ?? "No given name")
            print(familyName ?? "No family name")
            print(email ?? "No email")
            
            self.userService
                .createUser(params: [
                    "name": fullName ?? "No Name",
                    "email": email ?? "No email",
                    "googleToken": idToken ?? "No Token"
                ])
                .trackNetworkError(errorTracker)
                .asDriverOnErrorJustComplete()
                .drive(onNext: {
                    print("Success creating user: \($0)")
                    AppController.shared.setCurrentUser($0)
                    NotificationCenter.default.post(name: .createOnboarding, object: nil)
                })
                .disposed(by: disposeBag)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        print(error)
    }
    
}

extension SignupViewController: GIDSignInUIDelegate {
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension SignupViewController {
    
    private func setupGoogleButton() {
        GIDSignIn.sharedInstance().uiDelegate = self
        googleButton = GIDSignInButton()
        googleButton.style = .iconOnly
        
        view.addSubview(googleButton)
        googleButton.snp.makeConstraints { (make) in
            //make.width.equalTo(view).multipliedBy(0.8)
            make.center.equalTo(view)
            make.height.equalTo(56)
        }
    }
    
}
