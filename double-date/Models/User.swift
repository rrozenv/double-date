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
    let firstName: String
    let lastName: String
    let gender: Gender
    let occupation: String
    let companyName: String
    
    enum CodingKeys: String, CodingKey {
        case _id
        case email
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
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
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
        firstName = try values.decodeIfPresent(String.self, forKey: .firstName) ?? "Default First Name"
        lastName = try values.decodeIfPresent(String.self, forKey: .lastName) ?? "Default Last Name"
        gender = try values.decodeIfPresent(Gender.self, forKey: .gender) ?? .male
        occupation = try values.decodeIfPresent(String.self, forKey: .occupation) ?? "Default Occupation"
        companyName = try values.decodeIfPresent(String.self, forKey: .companyName) ?? "Default Company Name"
    }
    
}



