//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 19.12.2023.
//
// j_BUsqs/5KE2GY!

import Foundation

final class OAuth2Service {
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = buildRequestURL(with: code) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        print("URL request: \(request)")
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request) { data, response, error in
            self.handleResponse(data: data, response: response, error: error, completion: completion)
        }.resume()
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
    
    private func handleResponse(data: Data?, response: URLResponse?, error: Error?, completion: @escaping (Result<String, Error>) -> Void) {
        guard let data = data,
              let response = response as? HTTPURLResponse,
              200..<300 ~= response.statusCode,
              error == nil else {
            DispatchQueue.main.async {
                completion(.failure(error ?? URLError(.badServerResponse)))
            }
            return
        }

        do {
            let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
            DispatchQueue.main.async {
                completion(.success(tokenResponse.accessToken))
                OAuth2TokenStorage().token = tokenResponse.accessToken
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
}
