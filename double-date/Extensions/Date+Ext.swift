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
    
    var iso8601String: String {
        return DateFormatter.iso8601.string(from: self)
    }
    
}

extension DateFormatter {
    
    static var iso8601: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter
    }
    
}
