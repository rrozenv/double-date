//
//  TwilioService.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/14/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct TwilioService {
    
    private let phoneNetwork = Network<TwilioPhoneResponse>(Secrets.twilioBaseURL)
    private let verifCodeNetwork = Network<TwilioCodeResponse>(Secrets.twilioBaseURL)
    private let sendCodePath = "phones/verification/start"
    private let headers = ["X-Authy-API-Key": Secrets.twilioProdKey]
    
    func sendVerificationCode(params: [String: Any]) -> Observable<TwilioPhoneResponse> {
        return phoneNetwork.postItem(sendCodePath,
                                     parameters: params,
                                     headers: headers)
    }
    
    func validateVerificationCode(params: [String: Any]) -> Observable<TwilioCodeResponse> {
        return verifCodeNetwork.getItem("phones/verification",
                                        parameters: params,
                                        encoding: URLEncoding.default,
                                        itemId: "check",
                                        headers: headers)
    }
    
}


