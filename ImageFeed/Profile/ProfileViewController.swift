//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 18.11.2023.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private let tokenStoreg = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let profileLogoutService = ProfileLogoutService.shared
    
    private let splashViewController = SplashViewController()
    private var profileImage: UIImageView?
    private var nameLabel: UILabel?
    private var loginNametLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var profileImageServiceObserver: NSObjectProtocol?      
       
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showPersonalInformation()
        fetchProfile()
        updateProfileDetails(profile: profileService)
        addProfileImageObserver()
    }
    
    private func addProfileImageObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
    }
    
    private func fetchProfile() {
        guard let token = tokenStoreg.token else {return}
        
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self.profileImageService.fetchProfileImageURL(username: profile.username) { _ in }
                case .failure:
                    AlertPresenter.showAletr(on: self, title: "Что-то пошло не так", message: "Не удалось войти в систему")
                    break
                }
            }
        }
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL),
            let profileImage = profileImage
        else { return }
        profileImage.kf.setImage(
            with: url,
            placeholder: UIImage(named: "user_photo"))
        profileImage.layer.cornerRadius = 35
        profileImage.clipsToBounds = true
    }
    
    private func updateProfileDetails(profile: ProfileService) {
        guard let nameLabel = nameLabel,
              let loginNametLabel = loginNametLabel,
              let descriptionLabel = descriptionLabel else { return }
        nameLabel.text = profileService.profile?.name
        loginNametLabel.text = profileService.profile?.loginName
        descriptionLabel.text = profileService.profile?.bio
    }

    private func showPersonalInformation(){
        let indentation: CGFloat = 8
        
        let profileImage = UIImage(named: "NoUser")
        let avatarImageView = UIImageView(image: profileImage)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImageView)
        avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        self.profileImage = avatarImageView
        
        let nameLabel = UILabel()
        nameLabel.text = "Name"
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: indentation).isActive = true
        nameLabel.textColor = .ypWhite
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        self.nameLabel = nameLabel
        
        let loginNametLabel = UILabel()
        loginNametLabel.text = "@ekaterina_nov"
        loginNametLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNametLabel)
        loginNametLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor).isActive = true
        loginNametLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: indentation).isActive = true
        loginNametLabel.textColor = .ypGray
        loginNametLabel.font = UIFont.systemFont(ofSize: 13)
        self.loginNametLabel = loginNametLabel
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: loginNametLabel.bottomAnchor, constant: indentation).isActive = true
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        self.descriptionLabel = descriptionLabel
        
        let logoutButton = UIButton.systemButton(
            with: UIImage(systemName: "ipad.and.arrow.forward")!,
            target: self,
            action: #selector(Self.didTapLogoutButton)
        )
        logoutButton.tintColor = .ypRed
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor).isActive = true
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        logoutButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }

    @objc private func didTapLogoutButton(){
        let alert = UIAlertController(title: "Пока, пока!", message: "Уверены что хотите выйти?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: {action in
            self.profileLogoutService.logout()
            self.present(self.splashViewController, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Нет", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
}
