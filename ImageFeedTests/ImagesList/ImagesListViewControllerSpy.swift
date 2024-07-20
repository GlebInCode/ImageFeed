//
//  ImagesListViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Глеб Хамин on 18.07.2024.
//

import ImageFeed
import Foundation

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: (any ImageFeed.ImagesListPresentorProtocol)?
    var didUpdateTableViewAnimated = false
    
    func updateTableViewAnimated() {
        didUpdateTableViewAnimated = true
    }
    
    
}
