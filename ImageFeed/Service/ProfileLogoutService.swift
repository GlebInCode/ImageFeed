//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 06.07.2024.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    private let tokenStorege = OAuth2TokenStorage.shared
    
    func logout() {
        cleanCookies()
        tokenStorege.deleteToken()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}

