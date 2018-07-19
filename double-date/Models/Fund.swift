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
    var cashBalance: Double
    var positions: [Position]
}

extension Portfolio {
    var positionsBuyValue: Double {
        return positions.reduce(0.0) { result, pos in
            return pos.isPendingBuy ?
                    result :
                    result + (pos.buyPrice * pos.shares)
        }
    }
    
    var positionsMarketValue: Double {
        return positions.reduce(0.0) { result, pos in
            return pos.isPendingBuy ?
                    result :
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
    let orderType: OrderType
    let ticker: String
    let buyPrice: Double
    let currentPrice: Double
    let shares: Double
    var sellPrice: Double?
}

extension Position {
    var totalPurchaseValue: Double {
        return buyPrice * shares
    }
    
    var profitLoss: Double {
        return (buyPrice * shares) - (currentPrice * shares)
    }
    
    var isPendingBuy: Bool {
        return orderType == .openLimit
    }
}

enum OrderType: String, Codable {
    case openLimit, closedLimit, market
}

struct Quote: Codable {
    let symbol: String
    let companyName: String?
    let latestPrice: Double
    let changePercent: Double
}

struct NewsArticle: Codable {
    let headline: String
    let source: String
    let url: String
    let summary: String
    let image: String
    //let datetime: Date
}

struct ChartPoint: Codable {
    let date: String
    let open: Double?
    let high: Double?
    let low: Double?
    let close: Double?
}

struct Stock: Codable {
    let quote: Quote
    let news: [NewsArticle]
    let chart: [ChartPoint]
}

struct StockSummary: Codable {
    let symbol: String
    let companyName: String?
}

struct Invitation: Codable {
    let _id: String
    let fund: String
    let fundName: String
    let sentBy: User
    let recievedByPhoneNumber: String
    //let recievedBy: User?
    let status: InvitationStatus
}

enum InvitationStatus: String, Codable {
    case accepted, rejected, pending
}

