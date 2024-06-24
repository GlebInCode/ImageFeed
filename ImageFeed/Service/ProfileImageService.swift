//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 26.03.2024.
//

import Foundation

final class ProfileImageService {
    
    //MARK: - Private Properties
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    static let shared = ProfileImageService()
    private init() {}
    
    private let tokenStoreg = OAuth2TokenStorage.shared
    
    private (set) var avatarURL: String?
    private var task: URLSessionTask?
    
    //MARK: - Lifecycle
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeFetchProfileImageURLRequest(username: username) else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let session = URLSession.shared
        let task = session.objectTask(for: request) {
            [weak self] (response: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                self?.task = nil
                switch response {
                case .success(let userResult):
                    self?.handleSuccess(userResult: userResult, completion: completion)
                case .failure(let error):
                    print("Ошибка сетевого запроса в функции \(#function): \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    //MARK: - Private Lifecycle
    
    private func handleSuccess(userResult: UserResult, completion: (Result<String, Error>) -> Void) {
        avatarURL = userResult.profileImage.large
        NotificationCenter.default.post(
            name: Self.didChangeNotification,
            object: self,
            userInfo: ["URL": avatarURL as Any])
        completion(.success(userResult.profileImage.large))
    }
    
    private func makeFetchProfileImageURLRequest(username: String) -> URLRequest? {
        guard let url = URL(string: Constants.profilePublicURLString + username) else { return nil }
        guard let token = tokenStoreg.token else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

