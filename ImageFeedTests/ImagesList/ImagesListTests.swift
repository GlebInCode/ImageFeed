//
//  ImagesListTests.swift
//  ImageFeedTests
//
//  Created by Глеб Хамин on 18.07.2024.
//

import XCTest
@testable import ImageFeed

final class ImagesListTests: XCTestCase {
    
    func ImagesListTestsNextPage() {
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        presenter.photosNextPage()
        
        XCTAssertTrue(presenter.didPhotoNexPage)
    }
    
    func ImagesListTestsObserver() {
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        presenter.addImageListObserver()
        
        XCTAssertTrue(presenter.didAddImageListObserver)
    }
    
    func ImagesListTestsUpdateTable() {
        let viewController = ImagesListViewControllerSpy()
        
        viewController.updateTableViewAnimated()
        
        XCTAssertTrue(viewController.didUpdateTableViewAnimated)
    }
}
