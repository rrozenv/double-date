//
//  User.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/13/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation

typealias JSONDictionary = [String: Any]

enum Gender: String, Codable {
    case male, female
}

struct User: Codable {
    let _id: String
    let email: String
    var firstName: String = ""
    var lastName: String = ""
    var gender: Gender = .male
    var occupation: String = ""
    var companyName: String = ""
}
