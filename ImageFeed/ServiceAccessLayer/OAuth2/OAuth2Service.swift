//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 19.12.2023.
//
// j_BUsqs/5KE2GY!

import Foundation

final class OAuth2Service {
    
    private struct OAuthTokenResponseBody: Decodable {
            let accessToken: String
            let tokenType: String
            let scope: String
            let createdAt: Int
        
            enum CodingKeys: String, CodingKey {
                case accessToken = "access_token"
                case tokenType = "token_type"
                case scope
                case createdAt = "created_at"
            }
    }
    
    func fetchAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
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
            URLQueryItem(name: "client_id", value: accessKey),
            URLQueryItem(name: "client_secret", value: secretKey),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
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


//final class OAuth2Service {
//
// static let shared = OAuth2Service()
//    private let urlSession = URLSession.shared
//    private (set) var authToken: String? {
//        get {
//            return OAuth2TokenStorage().token
//        }
//        set {
//            OAuth2TokenStorage().token = newValue
//} }
//    func fetchOAuthToken(
//        _ code: String,
//completion: @escaping (Result<String, Error>) -> Void ){
//        let request = authTokenRequest(code: code)
//        let task = object(for: request) { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let body):
//                let authToken = body.accessToken
//                self.authToken = authToken
//                completion(.success(authToken))
//            case .failure(let error):
//                completion(.failure(error))
//} }
//        task.resume()
//    }
//}
//extension OAuth2Service {
//    private func object(
//        for request: URLRequest,
//        completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void
//    ) -> URLSessionTask {
//        let decoder = JSONDecoder()
//        return urlSession.data(for: request) { (result: Result<Data, Error>) in
//            let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
//                Result { try decoder.decode(OAuthTokenResponseBody.self, from: data) }
//}
//            completion(response)
//        }
//}
//    private func authTokenRequest(code: String) -> URLRequest {
//        URLRequest.makeHTTPRequest(
//            path: "/oauth/token"
//            + "?client_id=\(accessKey)"
//            + "&&client_secret=\(secretKey)"
//            + "&&redirect_uri=\(redirectURI)"
//            + "&&code=\(code)"
//            + "&&grant_type=authorization_code",
//            httpMethod: "POST",
//            baseURL: URL(string: "https://unsplash.com")!
//) }
//    private struct OAuthTokenResponseBody: Decodable {
//        let accessToken: String
//        let tokenType: String
//        let scope: String
//        let createdAt: Int
//        enum CodingKeys: String, CodingKey {
//            case accessToken = "access_token"
//            case tokenType = "token_type"
//            case scope
//            case createdAt = "created_at"
//        }
//} }
//// MARK: - HTTP Request
//
//extension URLRequest {
//    static func makeHTTPRequest(
//        path: String,
//        httpMethod: String,
//        baseURL: URL = defaultBaseURL
//) -> URLRequest {
// 
//
//var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
//        request.httpMethod = httpMethod
//        return request
//} }
//// MARK: - Network Connection
//enum NetworkError: Error {
//    case httpStatusCode(Int)
//    case urlRequestError(Error)
//    case urlSessionError
//}
//extension URLSession {
//    func data(
//        for request: URLRequest,
//        completion: @escaping (Result<Data, Error>) -> Void
//    ) -> URLSessionTask {
//        let fulfillCompletion: (Result<Data, Error>) -> Void = { result in
//            DispatchQueue.main.async {
//                completion(result)
//            }
//}
//        let task = dataTask(with: request, completionHandler: { data, response, error in
//            if let data = data,
//                let response = response,
//                let statusCode = (response as? HTTPURLResponse)?.statusCode
//            {
//                if 200 ..< 300 ~= statusCode {
//                    fulfillCompletion(.success(data))
//                } else {
//                    fulfillCompletion(.failure(NetworkError.httpStatusCode(statusCode)))
//                }
//            } else if let error = error {
//                fulfillCompletion(.failure(NetworkError.urlRequestError(error)))
//            } else {
//                fulfillCompletion(.failure(NetworkError.urlSessionError))
//            }
//        })
//        task.resume()
//        return task
//} }
