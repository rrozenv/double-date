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
    var currentUserPortfolio: Portfolio
    let portfolios: [String]
}

struct Portfolio: Codable, Identifiable {
    let _id: String
    let user: User
    let cashBalance: Double
    var positions: [Position]
}

extension Portfolio {
    var positionsBuyValue: Double {
        return positions.reduce(0.0) { result, pos in
            result + (pos.buyPrice * pos.shares)
        }
    }
    
    var positionsMarketValue: Double {
        return positions.reduce(0.0) { result, pos in
            result + (pos.currentPrice * pos.shares)
        }
    }
    
    var portfolioROI: Double {
        return (positionsMarketValue - positionsBuyValue) / positionsMarketValue
    }
}

struct Position: Codable, Identifiable {
    let _id: String
    let user: String
    let fundIds: [String]
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

