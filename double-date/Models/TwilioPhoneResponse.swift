//
//  TwilioPhoneResponse.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/14/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation

struct TwilioPhoneResponse: Codable {
    let carrier: String
    let is_cellphone: Bool
    let message: String
    let seconds_to_expire: Int
    let uuid: String
    let success: Bool
}

struct TwilioCodeResponse: Codable {
    let message: String
    let success: Bool
}

