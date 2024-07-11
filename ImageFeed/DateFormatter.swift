//
//  DateFormatter.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 11.07.2024.
//

import Foundation

final class CustomDateFormatter {
    static let shared = CustomDateFormatter()
    private init() {}
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    lazy var iso8601DateFormatter = ISO8601DateFormatter()
}
