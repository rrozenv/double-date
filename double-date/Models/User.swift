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

struct User {
    let _id: String
    let email: String
    let name: String
    let gender: Gender
    let occupation: String
    let companyName: String
    
    enum CodingKeys: String, CodingKey {
        case _id
        case email
        case name
        case firstName
        case lastName
        case gender
        case occupation
        case companyName
    }
}

extension User: Encodable {
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encode(email, forKey: .email)
        try container.encode(name, forKey: .name)
        try container.encode(gender, forKey: .gender)
        try container.encode(occupation, forKey: .occupation)
        try container.encode(companyName, forKey: .companyName)
    }
    
}

extension User: Decodable {

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        _id = try values.decode(String.self, forKey: ._id)
        email = try values.decode(String.self, forKey: .email)
        name = try values.decode(String.self, forKey: .name)
        gender = try values.decodeIfPresent(Gender.self, forKey: .gender) ?? .male
        occupation = try values.decodeIfPresent(String.self, forKey: .occupation) ?? "Default Occupation"
        companyName = try values.decodeIfPresent(String.self, forKey: .companyName) ?? "Default Company Name"
    }
    
}




