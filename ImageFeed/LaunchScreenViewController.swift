//
//  LaunchScreenViewController.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 22.06.2024.
//

import UIKit

final class LaunchScreenViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showLaunchScreenView()
    }
    
    private func showLaunchScreenView() {
        view.backgroundColor = .ypBlack
        let logoImageView = UIImageView()
        logoImageView.image = UIImage(named:  "Logo")
        logoImageView.frame = CGRect(x: 0, y: 0, width: 75, height: 75)
        logoImageView.center.x = view.center.x
        logoImageView.center.y = view.frame.height / 3
        view.addSubview(logoImageView)
    }
}
