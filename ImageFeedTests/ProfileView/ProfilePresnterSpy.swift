//
//  ProfilePresnterSpy.swift
//  ImageFeedTests
//
//  Created by Глеб Хамин on 17.07.2024.
//

import ImageFeed
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var viewDidLoadCalled = false
    var view: ProfileViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
}
