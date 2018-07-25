//
//  UserService.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/13/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct UserService {
    
    let network = Network<User>(Secrets.baseURL)
    private let disposeBag = DisposeBag()
    
    func getCurrentUser() -> Observable<User> {
        return network.getItem("users", itemId: "me")
    }
    
    func createUser(params: [String: Any]) -> Observable<User> {
        return network.postUser("users", parameters: params)
    }
    
    func loginUser(phoneNumber: String) -> Observable<User> {
        return network.loginUser("users/login", parameters: ["phoneNumber": phoneNumber], encoding: URLEncoding.default)
    }

    func findUserBy(email: String) -> Observable<User?> {
        return network.getOptionalItem("users", itemId: email)
    }
    
    func setApnTokenFor(user: User, token: String) {
        network.postItem("users/\(user._id)/apnToken",
                                parameters: ["token": token])
            .subscribe()
            .disposed(by: disposeBag)
    }
    
}

