//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 29.01.2024.
//

import Foundation

enum NetworkError: Error {
    case decodingError(Error)
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
}

final class ProfileService{
    private(set) var profile: Profile?
    private var currentTask: URLSessionTask?
    
    static let shared = ProfileService()
    
        private init() {}
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        currentTask?.cancel()
        
        guard let request = makeFetchProfileRequest(token: token) else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        currentTask = fetch(request: request) { [weak self] response in
            self?.currentTask = nil
            switch response {
            case .success(let profileResult):
                let profile = Profile(result: profileResult)
                self?.profile = profile
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        func fetch(request: URLRequest, completion: @escaping (Result<ProfileResult, Error>) -> Void) -> URLSessionTask {
            let fulfillCompletionOnMainThread: (Result<ProfileResult, Error>) -> Void = {
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
                            let result = try decoder.decode(ProfileResult.self, from: data)
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
    }
    
    private func makeFetchProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: Constants.profileURLString) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
        //        URLRequest.makeHTTPRequest(
        //            path: "/me",
        //            httpMethod:"GET",
        //            baseURLString: Constants.defaultBaseURL
        //        )
    }
}
