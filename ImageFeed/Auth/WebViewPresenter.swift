//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 16.07.2024.
//

import Foundation

//MARK: - WebViewPresenterProtocol

public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

//MARK: - WebViewPresenter

final class WebViewPresenter: WebViewPresenterProtocol {
    
    //MARK: - Properties
    
    weak var view: (any WebViewViewControllerProtocol)?
    var authHelper: AuthHelperProtocol
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    //MARK: - ViewDidLoad
    
    func viewDidLoad() {
        guard let request = authHelper.authRequest() else { return }
        
        didUpdateProgressValue(0)
        
        view?.load(request: request)
    }
    
    //MARK: - Lifecycle
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
}


