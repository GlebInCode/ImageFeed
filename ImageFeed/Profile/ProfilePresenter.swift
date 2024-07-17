//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 16.07.2024.
//

import Foundation

//MARK: - ProfilePresenterProtocol

public protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    
}

//MARK: - ProfilePresenter

final class ProfilePresenter: ProfilePresenterProtocol {
    
    //MARK: - Properties
    
    weak var view: ProfileViewControllerProtocol?
    
    init(view: ProfileViewControllerProtocol) {
        self.view = view
    }
    
    private let tokenStoreg = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    //MARK: - ViewDidLoad
    
    func viewDidLoad() {
        fetchProfile()
        addProfileImageObserver()
        checkProfile()
    }
    
    //MARK: - Private Lifecycle
    
    private func fetchProfile() {
        guard let token = tokenStoreg.token else {return}
        
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self.profileImageService.fetchProfileImageURL(username: profile.username) { _ in }
                case .failure:
                    self.view?.alertError()
                    break
                }
            }
        }
    }
    
    private func addProfileImageObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.urlAvatar()
            }
    }
    
    private func urlAvatar() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        self.view?.updateAvatar(url: url)
    }
    
    private func checkProfile() {
        guard let profile = profileService.profile else { return }
        view?.updateProfileDetails(profile: profile)
    }
}
