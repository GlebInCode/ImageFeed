//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 19.06.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        )
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "galleryOn"),
            selectedImage: nil
        )
        
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "profileOn"),
            selectedImage: nil
        )
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}

