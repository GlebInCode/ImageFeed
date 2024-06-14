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

    private let oauth2Service = OAuth2Service()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if OAuth2TokenStorage().token != nil {
            fetchProfile()
            
        } else {
            // Show Auth Screen
            performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
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
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
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
                OAuth2TokenStorage().token = token
                self.switchToTabBarController()
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                // TODO [Sprint 11]
                break
            }
        }
    }
    private func fetchProfile() {
        guard let token = OAuth2TokenStorage().token else {return}
            UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token) { [weak self] result in
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss()
                    switch result {
                    case .success(let profile):
                        ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                        self?.switchToTabBarController()
                    case .failure:
                        //self?.showAlert()
                        break
                    }
                }
            }
        }
}
