//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 18.11.2023.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    private var avatarImageView: UIImageView?
    private var nameLabel: UILabel?
    private var loginNametLabel: UILabel?
    private var descriptionLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showPersonalInformation()
}

private func showPersonalInformation(){
    let indentation: CGFloat = 8
    
    let profileImage = UIImage(named: "User")
    let avatarImageView = UIImageView(image: profileImage)
    avatarImageView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(avatarImageView)
    avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
    avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
    avatarImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
    avatarImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
    
    let nameLabel = UILabel()
    nameLabel.text = "Екатерина Новикова"
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
}
    
}
