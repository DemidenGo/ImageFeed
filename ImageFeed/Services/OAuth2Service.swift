//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 03.12.2022.
//

import UIKit

//MARK: - OAuth2Protocol

protocol OAuth2ServiceProtocol {
    func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void)
}

//MARK: - OAuth2Service

final class OAuth2Service: OAuth2ServiceProtocol {

    private let unsplashTokenURLString = "https://unsplash.com/oauth/token"
    private var task: URLSessionTask?
    private var lastCode: String?

    private enum NetworkError: Error {
        case codeError
    }

    func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        let request = makeURLRequest(usingAuthCode: code)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            DispatchQueue.main.async {

                if let error = error {
                    completion(.failure(error))
                    self.lastCode = nil
                    return
                }

                if let response = response as? HTTPURLResponse,
                   response.statusCode < 200 && response.statusCode >= 300 {
                    completion(.failure(NetworkError.codeError))
                    return
                }

                guard let data = data else { return }
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let jsonResponse = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    let accessToken = jsonResponse.accessToken
                    completion(.success(accessToken))
                    self.task = nil
                } catch {
                    completion(.failure(error))
                    self.lastCode = nil
                    print("ERROR: \(error)")
                }
            }
        }
        self.task = task
        task.resume()
    }

    private func makeURLRequest(usingAuthCode code: String) -> URLRequest {
        guard let components = URLComponents(string: unsplashTokenURLString) else {
            preconditionFailure("Unable to construct unsplashTokenURLComponents")
        }
        var unsplashTokenURLComponents = components
        unsplashTokenURLComponents.queryItems = [
            URLQueryItem(name: "client_id", value: accessKey),
            URLQueryItem(name: "client_secret", value: secretKey),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        guard let url = unsplashTokenURLComponents.url else {
            preconditionFailure("Unable to construct unsplashTokenURL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
