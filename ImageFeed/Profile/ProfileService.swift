//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 29.01.2024.
//

import Foundation

final class ProfileService{
    private(set) var profile: Profile?
    private var task: URLSessionTask?
    
    static let shared = ProfileService()
    
        private init() {}
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        task?.cancel()
        
        guard let request = makeFetchProfileRequest(token: token) else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let session = URLSession.shared
        let task = session.objectTask(for: request) {
            [weak self] (response: Result<ProfileResult, Error>) in
            
            self?.task = nil
            switch response {
            case .success(let profileResult):
                let profile = Profile(result: profileResult)
                self?.profile = profile
                completion(.success(profile))
            case .failure(let error):
                print("Ошибка сетевого запроса в функции \(#function): \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
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
