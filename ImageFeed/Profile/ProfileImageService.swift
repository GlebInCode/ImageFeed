//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 26.03.2024.
//

import Foundation

final class ProfileImageService {
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    static let shared = ProfileImageService()
    private init() {}
    
    private (set) var avatarURL: String?
    private var task: URLSessionTask?
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeFetchProfileImageURLRequest(username: username) else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            
            NotificationCenter.default
                .post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": avatarURL])  // не знаю что идет после URL
            return
        }
        
        let session = URLSession.shared
        let task = session.objectTask(for: request) {
            [weak self] (response: Result<UserResult, Error>) in
            self?.task = nil
            switch response {
            case .success(let user):
                let user = User(result: user)
                self?.avatarURL = user.profileImage
                completion(.success(user.profileImage))
            case .failure(let error):
                print("Ошибка сетевого запроса в функции \(#function): \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    private func makeFetchProfileImageURLRequest(username: String) -> URLRequest? {
        guard let url = URL(string: Constants.profilePublicURLString + username) else { return nil }
        guard let token = OAuth2TokenStorage().token else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

