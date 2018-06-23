//
//  Fund.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/22/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation

struct Fund: Codable {
    let _id: String
    let name: String
    //let admin: User
    let maxPlayers: Int
//    let startDate: Date
//    let endDate: Date
//    let userPortfolio: Portfolio
//    let allPortfolios: [Portfolio]
}

struct Portfolio: Codable {
    let _id: String
    let user: User
    let positions: [Position]
}

struct Position: Codable {
    let _id: String
    let type: String
    let ticker: String
    let buyPrice: Double
    let currentPrice: Double
}

struct Invitation: Codable {
    let _id: String
    let fundId: String
    let sentBy: User
    let recievingPhoneNumber: String
    let recievedBy: User?
    let status: InvitationStatus
}

enum InvitationStatus: String, Codable {
    case accepted, rejected
}

