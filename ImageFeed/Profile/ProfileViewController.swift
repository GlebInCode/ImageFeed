//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 18.11.2023.
//

import UIKit
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func alertError()
    func updateAvatar(url: URL)
    func updateProfileDetails(profile: Profile?)
}

final class ProfileViewController: UIViewController,  ProfileViewControllerProtocol {
    
    //MARK: - Properties
    
    var presenter: ProfilePresenterProtocol?
    
    //MARK: - Private Properties
    
    private let profileLogoutService = ProfileLogoutService.shared
    private let splashViewController = SplashViewController()
    
    private var profileImage: UIImageView?
    private var nameLabel: UILabel?
    private var loginNametLabel: UILabel?
    private var descriptionLabel: UILabel?
    
    private var animationLayers = Set<CALayer>()
    private var gradientLayerAvatarImageView: CAGradientLayer?
    private var gradientLayerNameLabel: CAGradientLayer?
    private var gradientLayerLoginNametLabel: CAGradientLayer?
    private var gradientLayerDescriptionLabel: CAGradientLayer?
    
    //MARK: - ViewDidLoad
       
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = ProfilePresenter(view: self)
        showPersonalInformation()
        presenter?.viewDidLoad()
    }
    
    //MARK: - Lifecycle
    
    func alertError() {
        AlertPresenter.showAletr(on: self, title: "Что-то пошло не так", message: "Не удалось войти в систему")
    }
    
    // MARK: - UI Methods
    
    func updateAvatar(url: URL) {
        guard let profileImage = profileImage else { return }
        profileImage.kf.setImage(
            with: url,
            placeholder: UIImage(named: "user_photo"))
        profileImage.layer.cornerRadius = 35
        profileImage.clipsToBounds = true
        gradientLayerAvatarImageView?.removeFromSuperlayer()
        animationLayers.removeAll()
    }
    
    func updateProfileDetails(profile: Profile?) {
        guard let profile = profile,
              let nameLabel = nameLabel,
              let loginNametLabel = loginNametLabel,
              let descriptionLabel = descriptionLabel else { return }
        nameLabel.text = profile.name
        loginNametLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
        gradientLayerNameLabel?.removeFromSuperlayer()
        gradientLayerLoginNametLabel?.removeFromSuperlayer()
        gradientLayerDescriptionLabel?.removeFromSuperlayer()
    }

    private func showPersonalInformation(){
        let indentation: CGFloat = 8
        
        let avatarImageView = UIImageView()
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImageView)
        avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        let gradientAvatarImageView = createGradientLayer(width: 70, height: 70)
        gradientLayerAvatarImageView = gradientAvatarImageView
        avatarImageView.layer.insertSublayer(gradientAvatarImageView, at: 0)
        self.profileImage = avatarImageView
        
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: indentation).isActive = true
        nameLabel.textColor = .ypWhite
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        let gradientNameLabel = createGradientLayer(width: 223, height: 24)
        gradientLayerNameLabel = gradientNameLabel
        nameLabel.layer.insertSublayer(gradientNameLabel, at: 0)
        self.nameLabel = nameLabel
        
        
        let loginNametLabel = UILabel()
        loginNametLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNametLabel)
        loginNametLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor).isActive = true
        loginNametLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: indentation).isActive = true
        loginNametLabel.textColor = .ypGray
        loginNametLabel.font = UIFont.systemFont(ofSize: 13)
        let gradientLoginNametLabel = createGradientLayer(width: 89, height: 18)
        gradientLayerLoginNametLabel = gradientLoginNametLabel
        loginNametLabel.layer.insertSublayer(gradientLoginNametLabel, at: 0)
        self.loginNametLabel = loginNametLabel
        
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: loginNametLabel.bottomAnchor, constant: indentation).isActive = true
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        let gradientDescriptionLabel = createGradientLayer(width: 67, height: 18)
        gradientLayerDescriptionLabel = gradientDescriptionLabel
        descriptionLabel.layer.insertSublayer(gradientDescriptionLabel, at: 0)
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
    
    // MARK: - Gradient & Loading animation
    
    private func createGradientLayer(width: Int, height: Int) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = CGFloat(height / 2)
        gradient.masksToBounds = true
        animationLayers.insert(gradient)
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
        
        return gradient
    }
    
    //MARK: - didTapLogoutButton

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
