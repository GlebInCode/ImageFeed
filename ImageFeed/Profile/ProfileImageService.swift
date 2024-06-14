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
    private var currentTask: URLSessionTask?
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeFetchProfileImageURLRequest(username: username) else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            
            NotificationCenter.default
                .post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": avatarURL])                    // не знаю что идет после URL
            return
        }
        
        currentTask = fetch(request: request) { [weak self] response in
            self?.currentTask = nil
            switch response {
            case .success(let user):
                let user = User(result: user)
                self?.avatarURL = user.profileImage
                completion(.success(user.profileImage))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetch(request: URLRequest, completion: @escaping (Result<UserResult, Error>) -> Void) -> URLSessionTask {
        let fulfillCompletionOnMainThread: (Result<UserResult, Error>) -> Void = {
            result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    do {
                        let decoder = JSONDecoder()
                        let result = try decoder.decode(UserResult.self, from: data)
                        fulfillCompletionOnMainThread(.success(result))
                    } catch {
                        fulfillCompletionOnMainThread(.failure(NetworkError.decodingError(statusCode as! Error)))
                    }
                } else {
                    fulfillCompletionOnMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletionOnMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletionOnMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        task.resume()
        return task
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

