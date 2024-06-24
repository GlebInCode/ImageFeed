//
//  UserResult.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 19.06.2024.
//

import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImage
    
    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let large: String
}
