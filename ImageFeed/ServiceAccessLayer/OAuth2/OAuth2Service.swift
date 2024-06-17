//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 19.12.2023.
//
// j_BUsqs/5KE2GY!

import Foundation

final class OAuth2Service {
    
    private let session = URLSession.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    var authToken: String? {
        get {
            return OAuth2TokenStorage().token
        }
        set {
            OAuth2TokenStorage().token = newValue
        }
    }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        
        guard let url = buildRequestURL(with: code) else {
            assertionFailure ("Invalid request")
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        
        let task = session.objectTask(for: request) {
            [weak self] (response: Result<OAuthTokenResponseBody, Error>) in
            
            self?.task = nil
            switch response {
            case .success(let body):
                let authToken = body.accessToken
                self?.authToken = authToken
                completion(.success (authToken))
            case .failure(let error):
                print("Ошибка сетевого запроса в функции \(#function): \(error.localizedDescription)")
                completion(. failure (error))
            }
        }
        task.resume()
    }
    
    
    private func buildRequestURL(with code: String) -> URL? {
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token")
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        return urlComponents?.url
    }
}
