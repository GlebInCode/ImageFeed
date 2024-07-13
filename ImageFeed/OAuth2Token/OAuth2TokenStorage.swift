//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 19.12.2023.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    private let tokenKey = "OAuth2Token"
    private let defaults = KeychainWrapper.standard
    
    var token: String? {
        get { defaults.string(forKey: tokenKey) }
        set {
            if let newValue = newValue {
                defaults.set(newValue, forKey: tokenKey)
            } else {
                defaults.removeObject(forKey: tokenKey)
            }
        }
    }
    
    func deleteToken() {
        defaults.removeObject(forKey: tokenKey)
        return
    }
    
    func hasToken() -> Bool {
            return KeychainWrapper.standard.hasValue(forKey: tokenKey)
        }
}
