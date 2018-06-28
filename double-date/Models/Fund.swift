//
//  Fund.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/22/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation

struct Fund: Codable, Identifiable {
    let _id: String
    let admin: User
    let name: String
    let maxPlayers: Int
    let currentUserPortfolio: Portfolio
    let portfolios: [String]
    
    //let portfolios: [Portfolio]
//    let startDate: Date
//    let endDate: Date
//    let userPortfolio: Portfolio
//    let allPortfolios: [Portfolio]
}

struct Portfolio: Codable {
    let _id: String
    let user: User
    //let positions: [Position]
}

struct Position: Codable {
    let _id: String
    let portfolioIds: [String]
    let type: String
    let ticker: String
    let buyPrice: Double
    let currentPrice: Double
    let shares: Double
    var sellPrice: Double?
}

struct Stock: Codable {
    let symbol: String
    let companyName: String
    let latestPrice: Double
    let changePercent: Double
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

