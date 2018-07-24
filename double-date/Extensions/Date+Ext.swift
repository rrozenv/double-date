//
//  Date+Ext.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/23/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation

extension Date {
    
    var dayMonthYearString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: self)
    }
    
    var dayMonthYearISO8601String: String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]
        return dateFormatter.string(from: self)
    }
    
}
