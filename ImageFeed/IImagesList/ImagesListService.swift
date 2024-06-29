//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 27.06.2024.
//

import Foundation

final class ImagesListService {
    
    static let shared = ImagesListService()
    private init() {}
    
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    private let tokenStoreg = OAuth2TokenStorage.shared
    private (set) var photos: [Photo] = []
    private var task: URLSessionTask?
    private var isFetching = false
    
    private var lastLoadedPage = 0
    
    func fetchPhotosNextPage() {
        
        guard !isFetching else { return }
        
        isFetching = true
        lastLoadedPage += 1
        guard let request = makeFetchPhotosRequest(nextPage: lastLoadedPage) else {
            isFetching = false
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let photoResults):
                    self?.handleSuccess(photoResults: photoResults)
                case .failure(let error):
                    self?.lastLoadedPage -= 1
                    assertionFailure("Ошибка получения изображений \(error)")
                }
            }
        }
        task.resume()
    }
    
    private func makeFetchPhotosRequest(nextPage: Int) -> URLRequest? {
        guard let url = URL(string: Constants.defaultPhotos + "?page=\(nextPage)"),
              let token = tokenStoreg.token else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    private func handleSuccess(photoResults: [PhotoResult]) {
        let newPhotos = photoResults.map { Photo(from: $0) }
        photos.append(contentsOf: newPhotos)
        NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
    }
}
