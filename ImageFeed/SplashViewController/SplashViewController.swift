//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 19.12.2023.
//

import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    
    
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    private let oauth2Service = OAuth2Service.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var tokenStoreg = OAuth2TokenStorage.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showSplashView()
        if tokenStoreg.hasToken() {
            fetchProfile()
        } else {
            showAuthScreen()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    private func showAuthScreen() {
        guard let authViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
        //let authViewController = AuthViewController()
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true, completion: nil)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            UIBlockingProgressHUD.show()
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                tokenStoreg.token = token
                self.switchToTabBarController()
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                AlertPresenter.showAletr(on: self, title: "Что-то пошло не так", message: "Не удалось войти в систему")
                break
            }
        }
    }
    private func fetchProfile() {
        guard let token = tokenStoreg.token else {return}
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success(let profile):
                    self.profileImageService.fetchProfileImageURL(username: profile.username) { _ in }
                    self.switchToTabBarController()
                case .failure:
                    AlertPresenter.showAletr(on: self, title: "Что-то пошло не так", message: "Не удалось войти в систему")
                    break
                }
            }
        }
    }
    private func showSplashView() {
        view.backgroundColor = .ypBlack
        let imageView = UIImageView(image: UIImage(named: "Logo"))
        imageView.frame = CGRect(x: 0, y: 0, width: 75, height: 75)
        imageView.center.x = view.center.x
        imageView.center.y = view.frame.height / 3
        view.addSubview(imageView)
    }
    //    private func fetchImageProfile(userName: String) {
    //        profileImageService.fetchProfileImageURL(username: userName) { [weak self] result in
    //            DispatchQueue.main.async {
    //                switch result {
    //                case .success(let imageURL):
    //                    print("Profile Image URL: \(imageURL)")
    //                case .failure(let error):
    //                    print("Error fetching profile image URL: \(error)")
    //                }
    //            }
    //        }
    //    }
}
