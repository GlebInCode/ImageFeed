//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 18.07.2024.
//

import Foundation

//MARK: - ImagesListPresentorProtocol

public protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    
    func photosNextPage()
    func addImageListObserver()
}

//MARK: - ImagesListPresentor

final class ImagesListPresentor: ImagesListPresenterProtocol {
    
    weak var view: ImagesListViewControllerProtocol?
    
    let imagesListService = ImagesListService.shared
    
    init(view: ImagesListViewControllerProtocol? = nil) {
        self.view = view
    }
    
    //MARK: - Methods
    
    func photosNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func addImageListObserver() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                self?.view?.updateTableViewAnimated()
            }
    }
}
