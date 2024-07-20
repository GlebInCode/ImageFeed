//
//  ImagesListPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Глеб Хамин on 18.07.2024.
//

import Foundation
import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresentorProtocol {
    var view: (any ImageFeed.ImagesListViewControllerProtocol)?
    var didPhotoNexPage = false
    var didAddImageListObserver = false
    
    func photosNextPage() {
        didPhotoNexPage = true
    }
    
    func addImageListObserver() {
        didAddImageListObserver = true
    }
    
    
}
