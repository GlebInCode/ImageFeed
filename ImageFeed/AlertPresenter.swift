//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 17.06.2024.
//

import UIKit

struct AlertPresenter {
    static func showAletr(on viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }
}
