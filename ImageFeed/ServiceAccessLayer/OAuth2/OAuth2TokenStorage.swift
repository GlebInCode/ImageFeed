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
    
    //private let defaults = UserDefaults.standard
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
    
    func delitToken() {
        defaults.removeObject(forKey: tokenKey)
        return
    }
    
//    var token: String? {
//        get { defaults.string(forKey: tokenKey) }
//        set { defaults.set(newValue, forKey: tokenKey) }
//    }
    
    private init() {}
}
