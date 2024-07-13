//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 27.06.2024.
//

import Foundation

struct PhotoResult: Codable {
    let id: String
    let createdAt: String
    let width, height: Int
    let likedByUser: Bool
    let description: String?
    let urls: Urls
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case likedByUser = "liked_by_user"
        case description
        case urls
    }
}

// MARK: - Urls
struct Urls: Codable {
    let full: String
    let thumb: String
}

struct LikePhotoResult: Decodable {
    let photo: PhotoResult?
}
