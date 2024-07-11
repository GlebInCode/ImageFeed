//
//  ProfileResultStructures.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 24.06.2024.
//

import Foundation

struct ProfileResult: Codable {
    let userLogin: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    private enum CodingKeys: String, CodingKey {
        case userLogin = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}
