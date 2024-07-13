//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 27.06.2024.
//

import Foundation

final class ImagesListService {
    
    //MARK: - Private Properties
    
    static let shared = ImagesListService()
    private init() {}
    
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    private let tokenStoreg = OAuth2TokenStorage.shared
    private (set) var photos: [Photo] = []
    private var task: URLSessionTask?
    private var lastLoadedPage = 0
    
    //MARK: - Lifecycle
    
    func fetchPhotosNextPage() {
        guard task == nil else { return }
        
        lastLoadedPage += 1
        guard let request = makeFetchPhotosRequest(nextPage: lastLoadedPage) else {
            assertionFailure ("Invalid request")
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let photoResults):
                    self?.handleSuccess(photoResults: photoResults)
                case .failure(let error):
                    self?.lastLoadedPage -= 1
                    print("Ошибка сетевого запроса в функции \(#function): \(error.localizedDescription)")
                }
                self?.task = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        task?.cancel()
        
        guard let request = fetchLikedPhotoRequest(photoId: photoId, isLike: isLike) else {
            assertionFailure ("Invalid request")
            self.task = nil
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<LikePhotoResult, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let index = self?.photos.firstIndex(where: { $0.id == photoId }) {
                        self?.photos[index].isLiked = isLike
                        NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
                    }
                    completion(.success(()))
                case .failure(let error):
                    print("Ошибка сетевого запроса в функции \(#function): \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    //MARK: - Private Lifecycle
    
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
    
    private func fetchLikedPhotoRequest(photoId: String, isLike: Bool) -> URLRequest? {
        guard let url = URL(string: Constants.defaultPhotos + "\(photoId)/like"),
              let token = tokenStoreg.token else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
