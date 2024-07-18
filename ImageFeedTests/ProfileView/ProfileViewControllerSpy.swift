//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Глеб Хамин on 17.07.2024.
//

import ImageFeed
import UIKit

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    
    var presenter: ImageFeed.ProfilePresenterProtocol?
    
    var didUpdateAvatar = false
    var didUpdateProfileDetails = false
    var didalertError = false
    
    func updateProfileDetails(profile: ImageFeed.Profile?) {
        didUpdateProfileDetails = true
    }
    
    func updateAvatar(url: URL) {
        didUpdateAvatar = true
    }
    
    func alertError() {
        didalertError = true
    }
}
