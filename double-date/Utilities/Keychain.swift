//
//  Keychain.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/24/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import KeychainAccess

final class MyKeychain {
    
    static let shared = MyKeychain()
    private let keychain = Keychain(server: Secrets.baseURL, protocolType: .https)
    
    private init() { }
    
    func getStringFor(_ key: String) -> String? {
        do {
            return try keychain.getString(key)
        }
        catch let error {
            print(error)
            return nil
        }
    }
    
    func save(value: String, key: String) -> Bool {
        do {
            try keychain.set(value, key: key)
            return true
        }
        catch let error {
            print(error)
            return false
        }
    }
    
    func removeValueFor(_ key: String) -> Bool {
        do {
            try keychain.remove(key)
            return true
        }
        catch let error {
            print(error)
            return false
        }
    }
    
    func removeAllValues() -> Bool {
        do {
            try keychain.removeAll()
            return true
        }
        catch let error {
            print(error)
            return false
        }
    }
    
}
