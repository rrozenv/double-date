//
//  API.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/13/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import Moya

enum API {
    case users(Users)
    
    enum Users {
        case me
        case allUsers
        case createUser(JSONDictionary)
    }
}

extension API: TargetType {
    
    // 3:
    var baseURL: URL {
        return URL(string: Secrets.baseURL)!
    }
    
    // 4:
    var path: String {
        switch self {
        case .users(let path):
            switch path {
            case .me: return "/me"
            case .allUsers: return "/users"
            case .createUser(_): return "/users"
            }
        }
    }
    
    // 5:
    var method: Moya.Method {
        switch self {
        case .users(let path):
            switch path {
            case .me: return .get
            case .allUsers: return .get
            case .createUser(_): return .post
            }
        }
    }
    
    // 6:
    var parameters: [String: Any] {
        switch self {
        case .users(let path):
            switch path {
            case .me: return [:]
            case .allUsers: return [:]
            case .createUser(let body): return body
            }
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    // 7:
    var parameterEncoding: ParameterEncoding {
       return JSONEncoding.default
    }
    
    // 8:
    var sampleData: Data {
        return Data()
    }
    
    // 9:
    var task: Task {
        return .requestParameters(parameters: parameters, encoding: parameterEncoding)
    }
}
