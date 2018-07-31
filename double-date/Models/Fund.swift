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
    let startDate: Date
    let endDate: Date
    var currentUserPortfolio: Portfolio
    let portfolios: [String]
}

extension Fund {
    var daysLeft: Int {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day
        print("days left: \(days ?? 0)")
        return days ?? 0
    }
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
                    result + (pos.status != .open ? (pos.sellPrice! * pos.shares) : (pos.currentPrice * pos.shares))
        }
    }
    
    var netEquity: Double {
        return (positionsMarketValue - positionsBuyValue) + cashBalance
    }
    
    var portfolioROI: Double {
        guard positions.isNotEmpty else { return 0.0 }
        return (positionsMarketValue - positionsBuyValue) / positionsMarketValue
    }
}

struct Position: Codable, Identifiable {
    let _id: String
    let user: String
    let status: PositionStatus
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
    
    var profitLossDouble: Double {
        if let sellPrice = sellPrice, status == .closed {
            return (sellPrice * shares) - (buyPrice * shares)
        } else {
            return (currentPrice * shares) - (buyPrice * shares)
        }
    }
    
    var positionROI: Double {
        if let sellPrice = sellPrice, status == .closed {
            return (sellPrice - buyPrice) / sellPrice
        } else {
            return (currentPrice - buyPrice) / currentPrice
        }
    }
    
    var isPendingBuy: Bool {
        return orderType == .openLimit
    }
}

extension Array where Element == Position {
    
    func totalReturn() -> Double {
        let totalPAndL = self.reduce(0) { (result, pos) in pos.isPendingBuy ? result : result + pos.profitLossDouble }
        let totalInvested = self.reduce(0) { (result, pos) in pos.isPendingBuy ? result : result + pos.totalPurchaseValue }
        return totalPAndL / totalInvested
    }
    
}

enum OrderType: String, Codable {
    case openLimit, closedLimit, market
}

enum PositionStatus: String, Codable {
    case open, closed
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

