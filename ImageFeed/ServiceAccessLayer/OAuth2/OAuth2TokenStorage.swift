//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 19.12.2023.
//

import Foundation

final class OAuth2TokenStorage {
    
    private let defaults = UserDefaults.standard
    private let tokenKey = "OAuth2Token"
    
    var token: String? {
        get { defaults.string(forKey: tokenKey) }
        set { defaults.set(newValue, forKey: tokenKey) }
    }
}
