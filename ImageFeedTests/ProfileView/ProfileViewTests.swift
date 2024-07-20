//
//  ProfileViewTests.swift
//  ImageFeedTests
//
//  Created by Глеб Хамин on 17.07.2024.
//

import XCTest
@testable import ImageFeed

final class ProfileViewTests: XCTestCase {
    
    func testProfileViewControllerCalledViewDidLoad() {
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        _ = viewController.view
        presenter.viewDidLoad()
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testProfileViewControllerUpdateAvater() {
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        let url = AuthConfiguration.standard.defaultBaseURL
        
        presenter.view?.updateAvatar(url: url)
        
        XCTAssertTrue(viewController.didUpdateAvatar)
    }
    
    func testProfileViewControllerUpdateProfileDetails() {
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        let profile = Profile(
            username: "",
            name: "",
            loginName: "",
            bio: ""
        )
        
        presenter.view?.updateProfileDetails(profile: profile)
        
        XCTAssertTrue(viewController.didUpdateProfileDetails)
    }
}
